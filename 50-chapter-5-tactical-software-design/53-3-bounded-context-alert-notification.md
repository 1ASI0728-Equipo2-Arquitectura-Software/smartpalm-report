
## 5.3.3. Application Layer

#### Command y Query Services

| Nombre | Categoría | Dependencias principales | Métodos y propósito |
| :--- | :--- | :--- | :--- |
| AlertCommandService | Command Service | Repositorios de alerta/settings, `IUnitOfWork`, `IIntegrationEventWriter` | `AcknowledgeAsync` valida acceso y emite `alert.acknowledged`; `UpdateSettingAsync` realiza el upsert de preferencia. |
| AlertQueryService | Query Service | `IAlertRepository`, `IUserAlertSettingRepository` | Sobrecargas `HandleAsync` para queries de alertas y settings; devuelve `AlertResponse` o `UserAlertSettingResponse`. |
| IntegrationEventHandlers | Event Handler | Repositorios, políticas, Inbox, Unit of Work y Outbox | Consume threshold/cambios Crop; clasifica, suprime duplicados y crea alerta/entrega de forma idempotente. |
| IInbox / IIntegrationEventWriter / IPushNotificationService | Application Ports | — | Declaran idempotencia, Outbox y envío de `PushNotification` con `PushDispatchResult`. |

| Componente | Métodos y responsabilidad |
|---|---|
| `AlertCommandService | Reconoce alertas y crea/actualiza settings, validando actor y estado. |
| AlertQueryService | Lista alertas por usuario/rol y resuelve settings sin exponer entidades EF. |
| IntegrationEventHandlers | Consume umbrales y proyecciones exactamente una vez; clasifica, suprime duplicados, crea `Alert`, `NotificationDelivery` y eventos Outbox. |
| IInbox / IIntegrationEventWriter | Puertos para idempotencia y Outbox. |
| IPushNotificationService | Puerto de notificaciones; `SendAsync(PushNotification)` devuelve `PushDispatchResult`. |

Solo alertas Critical con destinatario resuelto y sensor no silenciado generan entrega pendiente; la alerta siempre queda persistida aunque la entrega sea omitida.

