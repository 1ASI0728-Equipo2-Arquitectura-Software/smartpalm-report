# 5.3. Bounded Context: Alert & Notification

El bounded context **Alert & Notification** convierte eventos de telemetría fuera de umbral en alertas consultables y, si corresponde, notificaciones *push*. `SmartPalm.AlertService` es propietario del esquema PostgreSQL `alert`; consume eventos de **IngestionService** y **CropService** mediante RabbitMQ, mantiene proyecciones locales de plantaciones, sectores y afiliaciones, y usa Firebase Cloud Messaging a través de Firebase Admin SDK.

El servicio implementa seis capacidades: materializar proyecciones de Crop, clasificar desviaciones, suprimir duplicados, administrar preferencias de silencio, consultar alertas según rol y despachar notificaciones críticas. Las referencias de usuario, plantación y sector no son claves foráneas entre servicios: se resuelven por proyecciones locales y consistencia eventual.

## 5.3.1. Domain Layer

La **Domain Layer** concentra el agregado de alertas, entidades de proyección, vocabulario del dominio, políticas y contratos de repositorio. `Alert` protege el ciclo de vida de una alerta; las proyecciones permiten resolver contexto y visibilidad sin consultas síncronas hacia CropService.

##### 1. Alert

| Campo | Detalle |
|---|---|
| **Nombre** | Alert |
| **Categoría** | Entity / Aggregate Root |
| **Propósito** | Representar una lectura fuera de umbral, su contexto, severidad y reconocimiento. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `Id` | `long` | public, setter private | Identificador interno. |
| `SourceEventId`, `BatchId` | `Guid` | public, setter private | Evento recibido y lote de telemetría de origen. |
| `GatewayMacAddress`, `IotDeviceMacAddress` | `string` | public, setter private | Identificadores normalizados del origen físico. |
| `SensorType` | `SensorType` | public, setter private | Tipo de sensor que excedió el umbral. |
| `ReadingValue`, `ThresholdMin`, `ThresholdMax` | `double` | public, setter private | Lectura y rango permitidos usados en la clasificación. |
| `UserId`, `PlantationId`, `SectorId` | `long`, `long?`, `long?` | public, setter private | Destinatario y referencias de visibilidad. |
| `Message`, `Level`, `Status` | `string`, `AlertLevel`, `AlertStatus` | public, setter private | Mensaje, severidad y ciclo de vida. |
| `MeasuredAt`, `CreatedAtUtc`, `AcknowledgedAtUtc` | `DateTime`, `DateTime`, `DateTime?` | public, setter private | Tiempos de lectura, creación y reconocimiento. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| `Alert(...)` | — | public | Rechaza evento fuente vacío, mensaje vacío y límites invertidos; normaliza MACs y crea una alerta `Active`. |
| `Acknowledge(occurredAtUtc)` | `void` | public | Solo permite `Active → Acknowledged` y registra la fecha UTC. La autorización del actor se resuelve en Application. |
| `Normalize(value)` | `string` | public static | Rechaza identificadores vacíos y devuelve el valor sin espacios y en mayúsculas. |

---

##### 2. UserAlertSetting

| Campo | Detalle |
|---|---|
| **Nombre** | UserAlertSetting |
| **Categoría** | Entity |
| **Propósito** | Persistir la preferencia de silencio de un usuario por tipo de sensor. |

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `Id`, `UserId` | `long` | public, setter private | Identificador local y propietario de la configuración. |
| `SensorType`, `IsMuted`, `UpdatedAtUtc` | `SensorType`, `bool`, `DateTime` | public, setter private | Sensor configurado, estado de silencio y última modificación. |
| `UserAlertSetting(userId, sensorType, isMuted)` | — | public | Exige un usuario positivo y crea la configuración. |
| `Update(isMuted)` | `void` | public | Actualiza el silencio y `UpdatedAtUtc`. |

La combinación `UserId + SensorType` es única en persistencia.

---

##### 3. PlantationProjection

| Campo | Detalle |
|---|---|
| **Nombre** | PlantationProjection |
| **Categoría** | Entity / Event-derived projection |
| **Propósito** | Replicar la plantación de CropService para resolver localmente el Palm Grower destinatario. |

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `Id`, `PalmGrowerId`, `Name` | `long`, `long`, `string` | public, setter private | Identidad de plantación, propietario y nombre replicados. |
| `PlantationProjection(id, palmGrowerId, name)` | — | public | Crea la proyección al recibir la plantación. |
| `Refresh(palmGrowerId, name)` | `void` | public | Actualiza sus datos ante una nueva publicación. |

---

##### 4. SectorProjection

| Campo | Detalle |
|---|---|
| **Nombre** | SectorProjection |
| **Categoría** | Entity / Event-derived projection |
| **Propósito** | Asociar una MAC de dispositivo IoT con un sector y plantación locales. |

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `SectorId`, `PlantationId` | `long` | public, setter private | Identificadores publicados por CropService. |
| `IotDeviceMacAddress`, `IsActive` | `string`, `bool` | public, setter private | MAC normalizada y vigencia de la asignación. |
| `SectorProjection(...)` | — | public | Crea una asignación activa. |
| `Assign(plantationId, deviceMac)` | `void` | public | Actualiza o reactiva una asignación. |
| `Remove()` | `void` | public | La desactiva al recibir su remoción. |

---

##### 5. AgronomistAffiliationProjection

| Campo | Detalle |
|---|---|
| **Nombre** | AgronomistAffiliationProjection |
| **Categoría** | Entity / Event-derived projection |
| **Propósito** | Mantener la afiliación agrónomo-plantación requerida para filtrar visibilidad. |

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `AffiliationId`, `AgronomistId`, `PlantationId`, `IsActive` | `long`, `long`, `long`, `bool` | public, setter private | Identidad y estado de la afiliación replicada. |
| `AgronomistAffiliationProjection(...)` | — | public | Crea una afiliación activa. |
| `Activate(agronomistId, plantationId)` | `void` | public | Reactiva y actualiza la afiliación. |
| `Detach()` | `void` | public | Marca la afiliación como inactiva. |

---

##### 6. NotificationDelivery

| Campo | Detalle |
|---|---|
| **Nombre** | NotificationDelivery |
| **Categoría** | Entity |
| **Propósito** | Trazar el estado y los intentos de una notificación *push* asociada a una alerta. |

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `Id` | `Guid` | public, setter private | Identificador generado al crear la entrega. |
| `AlertId`, `UserId` | `long` | public, setter private | Alerta y destinatario. |
| `Status`, `AttemptCount` | `NotificationStatus`, `int` | public, setter private | Ciclo de entrega y número de intentos. |
| `CreatedAtUtc`, `AttemptedAtUtc` | `DateTime`, `DateTime?` | public, setter private | Creación y último intento. |
| `ProviderMessageId`, `Error` | `string?` | public, setter private | Identificador de Firebase o error/motivo truncado a 2000 caracteres. |
| `NotificationDelivery(alertId, userId, status, reason)` | — | public | Genera una entrega con fecha de creación. |
| `Dispatched(providerMessageId)` | `void` | public | Marca la entrega como enviada e incrementa los intentos. |
| `Failed(error)` | `void` | public | Registra un fallo reintentable e incrementa los intentos. |
| `Skip(reason)` | `void` | public | Registra una omisión definitiva e incrementa los intentos. |

---

##### 7. Value objects, enumeraciones y parser

| Nombre | Categoría | Valores o métodos | Propósito |
|---|---|---|---|
| `SensorType` | Enumeration | `Humidity`, `PH`, `Luminosity`, `Temperature`, `SoilMoisture` | Vocabulario de sensores alertables. |
| `AlertLevel` | Enumeration | `Informational`, `Warning`, `Critical` | Severidad de la desviación. |
| `AlertStatus` | Enumeration | `Active`, `Acknowledged`, `Suppressed` | Ciclo de vida de una alerta. |
| `NotificationStatus` | Enumeration | `Pending`, `Dispatched`, `Skipped`, `Failed` | Ciclo de vida de una entrega. |
| `SensorTypeParser` | Static helper | `TryParse(value, out sensorType): bool` | Convierte texto sin sensibilidad a mayúsculas y verifica que pertenezca al enum. |

---

##### 8. Domain services

| Nombre | Categoría | Atributos o métodos | Propósito |
|---|---|---|---|
| `AlertClassificationPolicy` | Domain Service | `Classify(value, min, max): AlertLevel` | Rechaza límites invertidos; desviación menor a 10% es `Informational`, menor a 30% es `Warning` y el resto `Critical`. |
| `DuplicateAlertPolicy` | Domain Service | `Window: TimeSpan`; `WindowStart(nowUtc): DateTime` | Define una ventana de supresión fija de 30 minutos; el repositorio busca la alerta reciente. |

---

##### 9. Repositorios y unidad de trabajo

| Nombre | Categoría | Métodos principales | Propósito |
|---|---|---|---|
| `IAlertRepository` | Repository interface | `AddAsync`, `GetAsync`, `FindRecentAsync`, `ListAllAsync`, `ListForUserAsync`, `CanAccessAsync` | Persistir, consultar, detectar duplicidad y validar acceso a alertas. |
| `IUserAlertSettingRepository` | Repository interface | `FindAsync`, `ListAsync`, `AddAsync` | Administrar preferencias por usuario y sensor. |
| `IProjectionRepository` | Repository interface | `GetPlantationAsync`, `FindSectorByDeviceAsync`, `GetSectorAsync`, `GetAffiliationAsync`, `FindAffiliationAsync`, `Add*Async` | Consultar y materializar proyecciones de Crop. |
| `INotificationDeliveryRepository` | Repository interface | `AddAsync` | Persistir una entrega de notificación. |
| `IUnitOfWork` | Unit of Work interface | `SaveChangesAsync`, `ExecuteAsync<T>` | Confirmar cambios y delimitar transacciones. |

---

##### 10. Commands y queries

| Nombre | Categoría | Parámetros | Propósito |
|---|---|---|---|
| `AcknowledgeAlertCommand` | Command record | `AlertId`, `UserId`, `Role`, `OccurredAtUtc` | Solicita el reconocimiento autorizado de una alerta. |
| `UpdateUserAlertSettingCommand` | Command record | `UserId`, `SensorType`, `IsMuted` | Crea o modifica una preferencia de silencio. |
| `GetAllAlertsQuery` | Query record | — | Solicita el listado administrativo. |
| `GetAlertsByUserIdQuery` | Query record | `UserId`, `Role` | Recupera alertas visibles para el actor. |
| `GetAlertByIdQuery` | Query record | `AlertId`, `UserId`, `Role` | Recupera una alerta solo si el actor tiene acceso. |
| `GetUserAlertSettingsQuery` | Query record | `UserId` | Lista preferencias de un usuario. |
| `GetUserAlertSettingQuery` | Query record | `UserId`, `SensorType` | Recupera una preferencia concreta. |

---

##### 11. Eventos de integración

Los consumidores trabajan con entrega *at least once*. Inbox registra el mensaje dentro de la transacción para evitar efectos duplicados; los eventos salientes se escriben primero en Outbox.

| Nombre | Dirección | Parámetros principales | Propósito |
|---|---|---|---|
| `ThresholdExceededIntegrationEvent` | Consumido desde Ingestion | `BatchId`, MACs, sensor, valor, mínimo, máximo, fecha | Crear o suprimir una alerta. |
| `PlantationCreatedIntegrationEvent` | Consumido desde Crop | Plantación, Palm Grower, nombre, hectáreas, fecha | Crear o refrescar la plantación local. |
| `SectorAssignedIntegrationEvent` | Consumido desde Crop | Sector, plantación, MAC, nombre, fecha | Crear o reactivar un sector. |
| `SectorRemovedIntegrationEvent` | Consumido desde Crop | Sector, plantación, MAC, fecha | Desactivar un sector local. |
| `AgronomistAffiliatedIntegrationEvent` | Consumido desde Crop | Afiliación, agrónomo, plantación, fecha | Crear o reactivar una afiliación. |
| `AgronomistDetachedIntegrationEvent` | Consumido desde Crop | Agrónomo, plantación, fecha | Desactivar una afiliación. |
| `AlertTriggeredIntegrationEvent` | Publicado | Alerta, usuario, plantación/sector, lectura, nivel, mensaje, fecha | Informar la persistencia de una alerta. |
| `AlertAcknowledgedIntegrationEvent` | Publicado | Alerta, usuario, fecha | Informar un reconocimiento confirmado. |
| `AlertSuppressedIntegrationEvent` | Publicado | Evento fuente, dispositivo, sensor, alerta existente, ventana, fecha | Informar una supresión por duplicidad. |
| `NotificationDispatchedIntegrationEvent` | Publicado | Entrega, alerta, usuario, identificador de proveedor, fecha | Informar una entrega *push* exitosa. |
