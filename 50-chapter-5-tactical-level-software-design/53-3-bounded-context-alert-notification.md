
## 5.3.3. Application Layer

La **Application Layer** orquesta casos de uso sin conocer HTTP, EF Core, RabbitMQ o Firebase. Separa comandos de consultas y usa Unit of Work, Inbox, Outbox y el puerto de notificaciones para mantener los adaptadores fuera de los flujos de negocio.

##### 1. AlertCommandService

| Campo | Detalle |
|---|---|
| **Nombre** | AlertCommandService |
| **Categoría** | Command Service |
| **Dependencias** | `IAlertRepository`, `IUserAlertSettingRepository`, `IUnitOfWork`, `IIntegrationEventWriter`. |
| **Propósito** | Reconocer alertas autorizadas y crear o actualizar preferencias. |

| Método | Tipo de retorno | Descripción |
|---|---|---|
| `AcknowledgeAsync(command, token)` | `Task` | Obtiene la alerta, verifica acceso, ejecuta `Acknowledge`, encola `alert.acknowledged.v1` y guarda cambios. |
| `UpdateSettingAsync(command, token)` | `Task<UserAlertSettingResponse>` | Busca la preferencia, la crea o actualiza y devuelve el DTO resultante. |

##### 2. AlertQueryService

| Campo | Detalle |
|---|---|
| **Nombre** | AlertQueryService |
| **Categoría** | Query Service |
| **Dependencias** | `IAlertRepository`, `IUserAlertSettingRepository`. |
| **Propósito** | Resolver las cinco queries sin exponer entidades de persistencia. |

| Método | Tipo de retorno | Descripción |
|---|---|---|
| `HandleAsync(GetAllAlertsQuery, token)` | `Task<IReadOnlyList<AlertResponse>>` | Lista alertas administrativas. |
| `HandleAsync(GetAlertsByUserIdQuery, token)` | `Task<IReadOnlyList<AlertResponse>>` | Lista alertas visibles por usuario y rol. |
| `HandleAsync(GetAlertByIdQuery, token)` | `Task<AlertResponse?>` | Devuelve una alerta solo si el actor tiene acceso. |
| `HandleAsync(GetUserAlertSettingsQuery, token)` | `Task<IReadOnlyList<UserAlertSettingResponse>>` | Lista preferencias del usuario. |
| `HandleAsync(GetUserAlertSettingQuery, token)` | `Task<UserAlertSettingResponse?>` | Devuelve una preferencia si existe. |

##### 3. IntegrationEventHandlers

| Campo | Detalle |
|---|---|
| **Nombre** | IntegrationEventHandlers |
| **Categoría** | Event Handler / Application Service |
| **Dependencias** | Repositorios, `IInbox`, `IUnitOfWork`, `IIntegrationEventWriter`, políticas de dominio y `ILogger`. |
| **Propósito** | Materializar eventos de Crop e Ingestion de forma idempotente, y crear o suprimir alertas. |

| Método | Tipo de retorno | Descripción |
|---|---|---|
| `HandleAsync(... ThresholdExceededIntegrationEvent ...)` | `Task` | Busca duplicados en 30 minutos; publica supresión o persiste alerta, entrega y evento disparado. |
| `HandleAsync(... PlantationCreatedIntegrationEvent ...)` | `Task` | Crea o refresca una plantación. |
| `HandleAsync(... SectorAssignedIntegrationEvent ...)` | `Task` | Crea o reactiva un sector. |
| `HandleAsync(... SectorRemovedIntegrationEvent ...)` | `Task` | Desactiva un sector existente. |
| `HandleAsync(... AgronomistAffiliatedIntegrationEvent ...)` | `Task` | Crea o reactiva una afiliación. |
| `HandleAsync(... AgronomistDetachedIntegrationEvent ...)` | `Task` | Desactiva la afiliación encontrada. |
| `OnceAsync(id, eventType, operation, token)` | `Task` | Verifica Inbox antes y durante la transacción, ejecuta una vez, marca el mensaje y guarda. |

Solo alertas `Critical` con destinatario resuelto y sensor no silenciado crean entregas `Pending`. Las demás se persisten, pero se registran como `Skipped` con una razón trazable.

##### 4. Contratos y puertos

| Nombre | Categoría | Campos o métodos | Propósito |
|---|---|---|---|
| `AlertResponse` | Response record | alerta, sensor, mensaje, nivel, estado, fecha | Contrato de salida de alertas. |
| `UserAlertSettingResponse` | Response record | sensor, silencio | Contrato de salida de preferencias. |
| `PushNotification` | Message record | título, cuerpo, tópico | Solicitud agnóstica de proveedor. |
| `PushDispatchResult` | Result record | enviado, identificador, razón, reintentable | Resultado del despacho. |
| `IInbox` | Application port | `HasProcessedAsync`, `MarkProcessed` | Contrato de idempotencia entrante. |
| `IIntegrationEventWriter` | Application port | `Enqueue(eventType, payload)` | Contrato de escritura transaccional en Outbox. |
| `IPushNotificationService` | Application port | `SendAsync(notification, token)` | Contrato para enviar notificaciones. |
