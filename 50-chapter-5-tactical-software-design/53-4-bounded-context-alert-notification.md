
## 5.3.4. Infrastructure Layer

La **Infrastructure Layer** materializa los puertos mediante PostgreSQL, RabbitMQ y Firebase. Ninguna tabla es compartida con otro microservicio: las proyecciones de Crop llegan como eventos y se almacenan en el esquema local `alert`.

##### 1. Persistencia y repositorios

| Nombre | Categoría | Propósito | Elementos relevantes |
|---|---|---|---|
| `AlertDbContext` | EF Core DbContext / `IUnitOfWork` | Mapear alertas, settings, entregas, proyecciones, Inbox y Outbox. | `ExecuteAsync<T>` abre una transacción, confirma al éxito y revierte ante error. |
| `AlertRepository` | Repository implementation | Implementar alertas, duplicidad y visibilidad. | Consultas por MAC/sensor/fecha y acceso por rol. |
| `UserAlertSettingRepository` | Repository implementation | Implementar preferencias por usuario/sensor. | Búsqueda, listado y alta. |
| `ProjectionRepository` | Repository implementation | Implementar proyecciones materializadas de Crop. | Búsquedas por identificador, MAC o afiliación. |
| `NotificationDeliveryRepository` | Repository implementation | Implementar el alta de entregas. | Agrega `NotificationDelivery` al DbContext. |
| `AlertDbContextFactory` | Design-time factory | Habilitar EF Core CLI. | Lee `AlertDatabase` desde `appsettings`, entorno y variables; usa Npgsql y `snake_case`. |
| `AlertDatabaseInitializer` | Database initializer | Aplicar migraciones al iniciar. | Reintenta hasta diez veces con espera de dos segundos. |

`AlertDbContext` configura `alerts`, `user_alert_settings`, `notification_deliveries`, las tres proyecciones, `inbox_messages` y `outbox_messages`. La única FK física de negocio es `notification_deliveries.alert_id → alerts.id`, con borrado en cascada. Índices únicos protegen `source_event_id`, usuario/sensor, MAC de sector y afiliación agrónomo/plantación.

##### 2. Mensajería e idempotencia

| Nombre | Categoría | Propósito | Comportamiento relevante |
|---|---|---|---|
| `Inbox` / `InboxMessage` | Inbox adapter / entity | Implementar `IInbox`. | Registra `messageId`, tipo de evento y fecha para evitar reprocesamiento. |
| `IntegrationEventWriter` / `OutboxMessage` | Outbox adapter / entity | Implementar `IIntegrationEventWriter`. | Serializa JSON con enums como texto y escribe el evento en la transacción actual. |
| `IntegrationEventConsumer` | RabbitMQ `BackgroundService` | Consumir los seis eventos de Ingestion y Crop. | Declara exchange/cola, usa ack manual y reencola ante error. |
| `OutboxPublisher` | RabbitMQ `BackgroundService` | Publicar eventos `alert.*.v1`. | Procesa hasta 100 mensajes, marca publicación y registra reintentos. |
| `NotificationDispatcher` | `BackgroundService` | Enviar entregas pendientes o fallidas. | Procesa hasta 50 entregas con menos de 10 intentos y publica la entrega confirmada. |

##### 3. Servicios externos, configuración y salud

| Nombre | Categoría | Propósito | Elementos relevantes |
|---|---|---|---|
| `FirebaseNotificationService` | Firebase adapter / `IPushNotificationService` | Enviar FCM por tópico. | `SendAsync` devuelve `PushDispatchResult`; usa configuración o `FIREBASE_CREDENTIALS_JSON` y se deshabilita con seguridad si faltan credenciales. |
| `RabbitMqOptions` | Configuration options | URI, exchange, cola y habilitación de RabbitMQ. | Se enlaza desde configuración. |
| `FirebaseOptions` | Configuration options | Habilitación, tópico y credenciales de Firebase. | No almacena secretos en el repositorio. |
| `DependencyInjection` | Composition root | Registrar adaptadores, repositorios, políticas y hosted services. | `AddAlertInfrastructure` exige `ConnectionStrings:AlertDatabase`. |
| `AlertDatabaseHealthCheck` | Health check | Verificar PostgreSQL. | `CheckHealthAsync` usa `CanConnectAsync`. |
