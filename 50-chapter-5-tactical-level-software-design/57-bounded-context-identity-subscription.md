
# 5.7. Bounded Context: Identity & Subscription Management

El bounded context **Identity & Subscription Management** es la autoridad de usuarios, autenticación, roles, planes, suscripciones y pagos de SmartPalm. `SmartPalm.IdentityService` es propietario del esquema PostgreSQL `identity`, preserva los claims JWT y contratos HTTP existentes, y publica hechos versionados mediante Outbox hacia el **Message Broker** implementado con RabbitMQ. Ningún bounded context consulta directamente su base de datos.

IdentityService no consume eventos ni mantiene proyecciones locales. FieldService y AgronomyService consumen de forma asíncrona los eventos de usuario y suscripción para materializar sus propias proyecciones de acceso.

## 5.7.1. Domain Layer

La **Domain Layer** no depende de ASP.NET Core, EF Core, RabbitMQ, BCrypt, JWT ni del procesador de pagos. Sus agregados encapsulan las transiciones de identidad, suscripción y pago; los repositorios y la unidad de trabajo son abstracciones que implementa la infraestructura.

### 1. User

| Campo | Detalle |
|---|---|
| **Nombre** | `User` |
| **Categoría** | Aggregate Root |
| **Propósito** | Representar identidad, credenciales hasheadas, rol y estado de acceso de un usuario SmartPalm. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `Id` | `int` | public get, private set | Identificador persistente. |
| `Username`, `PasswordHash` | `string` | public get, private set | Nombre único y hash BCrypt de la credencial. |
| `Email`, `FullName` | `string` | public get, private set | Datos de perfil validados. |
| `Role`, `Status` | `UserRole`, `UserStatus` | public get, private set | Rol de autorización y estado de acceso. |
| `CreatedAtUtc` | `DateTime` | public get, private set | Instante de creación UTC. |

**Métodos**

| Nombre | Parámetros | Retorno | Descripción e invariantes |
|---|---|---|---|
| `User` | username, password hash, email, nombre, rol | — | Exige textos no vacíos y límites de longitud; los usuarios nuevos empiezan `Active`. |
| `UpdateProfile` | nombre completo, email | `void` | Actualiza datos tras la misma validación de campos requeridos. |
| `RevokeAccess` | — | `void` | Transita el estado a `Inactive`. |
| `ActivateAccess` | — | `void` | Transita el estado a `Active`. |
| `Require` | valor, nombre, longitud máxima | `string` | Método privado estático que normaliza y valida texto. |

### 2. Subscription

| Campo | Detalle |
|---|---|
| **Nombre** | `Subscription` |
| **Categoría** | Aggregate Root |
| **Propósito** | Representar el plan contratado, su periodo de vigencia y el ciclo de estado de una suscripción. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `Id`, `UserId` | `int` | public get, private set | Identificador y referencia interna hacia `User`. |
| `PlanType`, `PlanName`, `Price`, `BillingCycle` | enum, `string`, `decimal`, enum | public get, private set | Instantánea del plan canónico contratado. |
| `Status` | `SubscriptionStatus` | public get, private set | Estado pendiente, activo, cancelado o expirado. |
| `StartDate`, `EndDate`, `CreatedAt` | `DateTime` | public get, private set | Vigencia normalizada en UTC y auditoría de creación. |

**Métodos**

| Nombre | Parámetros | Retorno | Descripción e invariantes |
|---|---|---|---|
| `Subscription` | usuario, `SubscriptionPlan`, fecha de inicio | — | Requiere usuario positivo; copia el plan, calcula un mes o año de vigencia y empieza `Pending`. |
| `Activate` | — | `void` | Solo permite la transición `Pending → Active`. |
| `Cancel` | — | `void` | Solo permite la transición `Active → Cancelled`. |

### 3. PaymentTransaction y SubscriptionPlan

| Nombre | Categoría | Atributos | Métodos y propósito |
|---|---|---|---|
| `PaymentTransaction` | Entity | `Id`, `UserId`, `PlanName`, periodo, monto, `TransactionId`, `Status`, `ProcessedAt`. | El constructor exige usuario válido, monto positivo y periodo ordenado. `Complete(transactionId)` y `Fail()` solo operan si el pago está `Pending`. |
| `SubscriptionPlan` | Value Object / record | `Type`, nombre, precio, ciclo y límites opcionales de hectáreas, sensores e historial. | Es inmutable; es una descripción canónica de oferta y no una entidad persistente. |
| `SubscriptionPlanCatalog` | Static Domain Service | No mantiene estado. | `Get(type)` resuelve los planes Seed, Harvest o Custom; `GetAll()` devuelve el catálogo completo. |

### 4. Enumeraciones, repositorios y Unit of Work

| Nombre | Categoría | Valores o métodos | Propósito |
|---|---|---|---|
| `UserRole` | Enum | `Administrator`, `Agronomist`, `PalmGrower` | Define autorización de usuario. |
| `UserStatus` | Enum | `Active`, `Inactive`, `Suspended` | Restringe acceso y autenticación. |
| `PlanType`, `BillingCycle` | Enums | Seed/Harvest/Custom; mensual/anual | Definen la oferta y la vigencia. |
| `SubscriptionStatus`, `PaymentStatus` | Enums | Estados de suscripción y pago | Restringen transiciones de negocio. |
| `IUserRepository` | Repository port | búsquedas por ID/nombre, existencias, lista y `Add` | Persistencia de `User`. |
| `ISubscriptionRepository` | Repository port | búsquedas por ID/usuario, lista y `Add` | Persistencia de `Subscription`. |
| `IPaymentRepository` | Repository port | lista por usuario y `Add` | Persistencia de `PaymentTransaction`. |
| `IUnitOfWork` | Transaction port | `SaveChangesAsync`, `ExecuteInTransactionAsync<T>` | Agrupa cambios de agregado y escritura Outbox. |

### 5. Commands, queries y eventos de integración

| Tipo | Campos | Propósito |
|---|---|---|
| `SignInCommand` | usuario, contraseña | Expresa autenticación con credenciales. |
| `CreateUserCommand` | usuario, contraseña, email, nombre, rol | Solicita el alta de una identidad. |
| `CreateSubscriptionCommand` | usuario, tipo de plan como texto | Solicita una suscripción y permite validar el plan en aplicación. |
| `CancelSubscriptionCommand` | usuario | Solicita la cancelación de la suscripción vigente. |
| `ProcessPaymentCommand` | usuario, monto | Solicita pagar y activar una suscripción pendiente. |
| `GetUserByIdQuery`, `GetAllUsersQuery` | ID; sin campos | Consultan perfiles de usuarios. |
| `GetSubscriptionByUserIdQuery`, `GetSubscriptionByIdQuery`, `GetAllSubscriptionsQuery` | usuario, suscripción; sin campos | Consultan estado de suscripciones. |
| `GetPaymentsByUserIdQuery`, `GetSubscriptionPlansQuery` | usuario; sin campos | Consultan pagos y catálogo de planes. |
| `UserCreatedIntegrationEvent` | usuario, nombre, email, nombre completo, rol, hora | Hecho publicado al registrar usuario. |
| `SubscriptionCreatedIntegrationEvent` | suscripción, usuario, plan, estado, hora | Hecho publicado al crear una suscripción pendiente. |
| `SubscriptionActivatedIntegrationEvent` | suscripción, usuario, plan, inicio, fin, hora | Hecho publicado tras un pago exitoso y activación. |
| `SubscriptionCancelledIntegrationEvent` | suscripción, usuario, hora | Hecho publicado al cancelar una suscripción activa. |

Los cuatro eventos se registran en Outbox dentro de la transacción de negocio y se publican con claves `smartpalm.identity.*.v1`; no son llamadas HTTP directas.

