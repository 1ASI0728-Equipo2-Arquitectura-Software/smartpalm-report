## 5.3.4. Infrastructure Layer

#### Implementaciones técnicas

| Nombre | Categoría | Propósito | Métodos o configuración relevante |
| :--- | :--- | :--- | :--- |
| AlertDbContext | EF Core DbContext | Mapear el esquema `alert` y actuar como `IUnitOfWork`. | DbSets de alertas, settings, proyecciones, Inbox, Outbox y entregas. |
| AlertRepository | Repository Implementation | Implementar `IAlertRepository`. | Consultas por usuario/rol, alerta reciente y verificación de acceso. |
| UserAlertSettingRepository | Repository Implementation | Implementar preferencias por usuario/sensor. | Búsqueda, listado y alta de settings. |
| ProjectionRepository | Repository Implementation | Mantener referencias materializadas de Crop. | Upsert de plantation, sector y afiliación. |
| NotificationDeliveryRepository | Repository Implementation | Gestionar entregas pendientes. | Alta y actualización del estado de dispatch. |
| IntegrationEventConsumer / Inbox | Messaging Consumer | Consumir eventos con ack manual e idempotencia. | `InboxMessage` registra el identificador ya procesado. |
| IntegrationEventWriter / OutboxPublisher | Messaging Publisher | Persistir y publicar eventos transaccionales. | `OutboxMessage` JSONB, confirmaciones y reintentos. |
| FirebaseNotificationService | External Service | Implementar `IPushNotificationService` mediante FCM. | `SendAsync` devuelve resultado enviado, omitido o reintentable; credenciales provienen de entorno. |

`AlertDbContext` configura `alerts`, `user_alert_settings`, `notification_deliveries`, las tres proyecciones, `inbox_messages` y `outbox_messages` en `alert`. `notification_deliveries.alert_id → alerts.id` es FK interna; índices únicos protegen event source, settings, MAC y afiliaciones.

`IntegrationEventConsumer` enlaza Ingestion y Crop, usa ack manual y reintentos; `Inbox` evita efectos duplicados. `OutboxPublisher` publica eventos `alert.*.v1`. `NotificationDispatcher` procesa entregas fuera de la transacción de alerta y `FirebaseNotificationService` implementa `IPushNotificationService` con Firebase Admin SDK; credenciales se inyectan por entorno. `RabbitMqOptions` y `FirebaseOptions` no contienen secretos en el repositorio.

`InboxMessage` y `OutboxMessage` son entidades de mensajería; `AlertDbContextFactory` habilita EF en diseño, `AlertDatabaseInitializer` aplica migraciones y `DependencyInjection` registra políticas, repositorios y adaptadores. `AlertResponse` y `UserAlertSettingResponse` son los contratos de salida consumidos por los controllers; `ClaimsPrincipalExtensions` encapsula la lectura de identidad.


