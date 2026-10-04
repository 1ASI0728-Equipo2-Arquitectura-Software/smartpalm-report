# 5.3. Bounded Context: Alert & Notification

Este bounded context convierte violaciones de umbrales en alertas consultables y, cuando corresponde, notificaciones push. `SmartPalm.AlertService` es propietario del esquema PostgreSQL `alert`, consume eventos de Ingestion y Crop por RabbitMQ y utiliza Firebase Admin SDK como adaptador externo. Las proyecciones de Identity/Crop son locales y no crean FK hacia otras bases.

## 5.3.1. Domain Layer

### Diccionario de clases del dominio

#### Aggregate: Alert

| Nombre: | Alert |
| :--- | :--- |
| **Categoría:** | Entity / Aggregate Root |
| **Propósito:** | Representar una violación de umbral ya clasificada, su destinatario, severidad y ciclo de reconocimiento. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
| :--- | :--- | :--- | :--- |
| Id | long | private | Identificador interno de la alerta. |
| SourceEventId / BatchId | Guid | private | Idempotencia del evento de origen y lote de telemetría. |
| GatewayMacAddress / IotDeviceMacAddress | string | private | Identificadores normalizados del origen físico. |
| SensorType, ReadingValue, ThresholdMin, ThresholdMax | enum / double | private | Medición que originó la alerta y su intervalo permitido. |
| UserId, PlantationId, SectorId | long / long? | private | Destinatario y referencias externas para visibilidad. |
| Message, Level, Status | string / enums | private | Mensaje, severidad y ciclo de vida. |
| MeasuredAt, CreatedAtUtc, AcknowledgedAtUtc | DateTime / DateTime? | private | Trazabilidad temporal de lectura, creación y reconocimiento. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
| :--- | :--- | :--- | :--- |
| Alert(...) | — | public | Valida evento, rango y mensaje; crea la alerta en estado `Active`. |
| Acknowledge(occurredAtUtc) | void | public | Permite la transición `Active → Acknowledged` una sola vez. |
| Normalize(value) | string | public static | Normaliza el identificador de gateway/dispositivo y rechaza valores vacíos. |

#### Entity: UserAlertSetting

| Nombre: | UserAlertSetting |
| :--- | :--- |
| **Categoría:** | Entity |
| **Propósito:** | Guardar la preferencia de silencio de un usuario por tipo de sensor. |

**Atributos y métodos**

| Nombre | Tipo / retorno | Visibilidad | Descripción |
| :--- | :--- | :--- | :--- |
| Id, UserId, SensorType, IsMuted, UpdatedAtUtc | long, long, SensorType, bool, DateTime | private | Identidad, alcance de la preferencia y fecha de actualización. |
| Update(isMuted) | void | public | Actualiza la preferencia; la combinación `UserId + SensorType` es única. |

#### Domain Services y Repository Interfaces

| Nombre | Categoría | Propósito | Métodos públicos principales |
| :--- | :--- | :--- | :--- |
| AlertClassificationPolicy | Domain Service | Clasificar la desviación de una lectura. | `Classify(value, min, max): AlertLevel`. |
| DuplicateAlertPolicy | Domain Service | Evitar alertas repetidas durante 30 minutos. | `ShouldSuppress(...) : bool`. |
| IAlertRepository | Repository | Persistir y consultar alertas con control de visibilidad. | `AddAsync`, `GetAsync`, `FindRecentAsync`, `ListAllAsync`, `ListForUserAsync`, `CanAccessAsync`. |
| IUserAlertSettingRepository | Repository | Persistir preferencias de silencio. | `FindAsync`, `ListAsync`, `AddAsync`. |
| IProjectionRepository | Repository | Acceder a proyecciones de Crop. | Operaciones de alta, actualización y consulta de proyecciones. |
| INotificationDeliveryRepository | Repository | Persistir el estado de entregas push. | Operaciones de alta, consulta y actualización de entregas. |
| IUnitOfWork | Repository / Unit of Work | Delimitar transacciones. | `SaveChangesAsync`, `ExecuteAsync`. |

#### Enums, commands, queries y eventos

| Tipo | Categoría | Valores o atributos relevantes | Propósito |
| :--- | :--- | :--- | :--- |
| SensorType | Enum | Humidity, PH, Luminosity, Temperature, SoilMoisture | Tipo de medición alertada. |
| AlertLevel | Enum | Informational, Warning, Critical | Severidad calculada. |
| AlertStatus | Enum | Active, Acknowledged, Suppressed | Ciclo de vida de `Alert`. |
| NotificationStatus | Enum | Pending, Dispatched, Skipped, Failed | Ciclo de una entrega push. |
| AcknowledgeAlertCommand | Command record | AlertId, UserId, Role, OccurredAtUtc | Solicita reconocimiento autorizado. |
| UpdateUserAlertSettingCommand | Command record | UserId, SensorType, IsMuted | Cambia la preferencia por sensor. |
| Get*Query | Query records | Usuario, rol o identificador según la consulta | Recuperan alertas y settings sin modificar el modelo. |
| *IntegrationEvent | Event records | Identificador, datos mínimos y timestamp | Consumen hechos de Ingestion/Crop y publican `alert.*.v1`. |

| Tipo / categoría | Atributos | Métodos, propósito e invariantes |
|---|---|---|
| `Alert` — aggregate root | `Id`, `SourceEventId`, `BatchId`, gateway/device, sensor, valor y límites, `UserId`, `PlantationId`, `SectorId`, `Message`, `Level`, `Status`, `MeasuredAt`, `CreatedAtUtc`, `AcknowledgedAtUtc`. | Constructor crea una alerta `Active`; `Acknowledge(userId)` solo permite una transición a `Acknowledged` y verifica actor autorizado. |
| `UserAlertSetting` — entity | `Id`, `UserId`, `SensorType`, `IsMuted`, `UpdatedAtUtc`. | `Update(isMuted)` cambia la preferencia; único lógico por usuario/sensor. |
| `PlantationProjection` — entity | `Id`, `PalmGrowerId`, `Name`. | Proyección de Crop para resolver destinatarios y visibilidad. |
| `SectorProjection` — entity | `SectorId`, `PlantationId`, `IotDeviceMacAddress`, `IsActive`. | Se actualiza con asignación/remoción de sector. |
| `AgronomistAffiliationProjection` — entity | `AffiliationId`, `AgronomistId`, `PlantationId`, `IsActive`. | Define visibilidad de alertas de un agrónomo. |
| `NotificationDelivery` — entity | `Id` UUID, `AlertId`, `UserId`, `Status`, `AttemptCount`, fechas, `ProviderMessageId`, `Error`. | `MarkAttempt`, `MarkDispatched` y `MarkFailed` controlan reintentos. |
| `SensorType`, `AlertLevel`, `AlertStatus`, `NotificationStatus` — enums | Vocabulario de sensor, severidad, ciclo de alerta y entrega. | Se convierten a texto en EF. |
| `SensorTypeParser` — domain helper | No posee estado. | Acepta representación numérica o textual de Ingestion y produce `SensorType`. |
| `AlertClassificationPolicy` — domain service | Umbrales de desviación 10%/30%. | `Classify(value,min,max)` devuelve Informational, Warning o Critical. |
| `DuplicateAlertPolicy` — domain service | Ventana de supresión de 30 minutos. | `ShouldSuppress(device,sensor,occurredAt,existing)` evita duplicados. |
| Repositories — interfaces | `IAlertRepository`, `IUserAlertSettingRepository`, `IProjectionRepository`, `INotificationDeliveryRepository`, `IUnitOfWork`. | Consultan/guardan agregados, settings, proyecciones y entregas; la unidad confirma la transacción. |

Commands: `AcknowledgeAlertCommand(AlertId, UserId)` y `UpdateUserAlertSettingCommand(UserId, SensorType, IsMuted)`. Queries: `GetAllAlertsQuery`, `GetAlertsByUserIdQuery`, `GetAlertByIdQuery`, `GetUserAlertSettingsQuery` y `GetUserAlertSettingQuery`.

Los eventos publicados son `AlertTriggeredIntegrationEvent`, `AlertAcknowledgedIntegrationEvent`, `AlertSuppressedIntegrationEvent` y `NotificationDispatchedIntegrationEvent`. Los handlers consumen `ThresholdExceededIntegrationEvent`, `PlantationCreatedIntegrationEvent`, `SectorAssignedIntegrationEvent`, `SectorRemovedIntegrationEvent`, `AgronomistAffiliatedIntegrationEvent` y `AgronomistDetachedIntegrationEvent`.

