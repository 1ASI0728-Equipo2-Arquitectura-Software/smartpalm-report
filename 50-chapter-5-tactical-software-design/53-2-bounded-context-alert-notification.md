## 5.3.2. Interface Layer

La **Interface Layer** del bounded context **Alert & Notification** concentra la consulta y gestión de alertas expuestas a los roles autenticados. Sus controllers traducen recursos HTTP en comandos o consultas, aplican la información de identidad del JWT y retornan DTOs, manteniendo aislados los agregados y proyecciones internas.

#### 1. AlertsController

| Campo | Detalle |
|---|---|
| **Nombre** | AlertsController |
| **Categoría** | Controller REST |
| **Ruta base** | `api/v1/alerts` |
| **Propósito** | Listar las alertas visibles para el usuario autenticado y registrar su reconocimiento. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `_commandService` | `AlertCommandService` | private readonly | Coordina el reconocimiento de alertas. |
| `_queryService` | `AlertQueryService` | private readonly | Filtra las alertas según el usuario y rol del JWT. |

**Métodos**

| Nombre | Verbo HTTP | Ruta | Tipo de retorno | Descripción |
|---|---|---|---|---|
| GetAlerts | GET | `/` | `Task<ActionResult<IReadOnlyList<AlertResource>>>` | Recupera las alertas permitidas para el usuario autenticado. |
| AcknowledgeAlert | PATCH | `/{alertId}` | `Task<IActionResult>` | Construye `AcknowledgeAlertCommand`, registra el reconocimiento y devuelve `204 No Content`. |

#### 2. AdminAlertsController

| Campo | Detalle |
|---|---|
| **Nombre** | AdminAlertsController |
| **Categoría** | Controller REST administrativo |
| **Ruta base** | `api/v1/admin/alerts` |
| **Propósito** | Consultar globalmente las alertas con autorización administrativa. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `_queryService` | `AlertQueryService` | private readonly | Obtiene el conjunto administrativo de alertas. |

**Métodos**

| Nombre | Verbo HTTP | Ruta | Tipo de retorno | Descripción |
|---|---|---|---|---|
| ListAlerts | GET | `/` | `Task<ActionResult<IReadOnlyList<AlertResource>>>` | Devuelve las alertas disponibles para administración. |

#### 3. UserAlertSettingsController

| Campo | Detalle |
|---|---|
| **Nombre** | UserAlertSettingsController |
| **Categoría** | Controller REST |
| **Ruta base** | `api/v1/alert-settings` |
| **Propósito** | Consultar y actualizar la preferencia de silenciamiento por tipo de sensor. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `_commandService` | `AlertCommandService` | private readonly | Crea o actualiza la configuración de alerta del usuario. |
| `_queryService` | `AlertQueryService` | private readonly | Recupera configuraciones de alerta existentes. |

**Métodos**

| Nombre | Verbo HTTP | Ruta | Tipo de retorno | Descripción |
|---|---|---|---|---|
| GetUserAlertSettings | GET | `/` | `Task<ActionResult<IReadOnlyList<UserAlertSettingResource>>>` | Lista las preferencias del usuario autenticado. |
| GetUserAlertSettingBySensorType | GET | `/{sensorType}` | `Task<ActionResult<UserAlertSettingResource>>` | Obtiene la preferencia de un tipo de sensor validado. |
| UpdateUserAlertSetting | PUT | `/{sensorType}` | `Task<ActionResult<UserAlertSettingResource>>` | Transforma `UpdateUserAlertSettingResource` y actualiza `IsMuted`. |

#### Resources y assemblers

`AlertResource`, `UserAlertSettingResource` y `UpdateUserAlertSettingResource` son records de transporte. `AlertResourceAssemblers` conserva las conversiones entre los recursos HTTP, los comandos y las respuestas del dominio. La autorización JWT permite al Palm Grower consultar sus alertas, al Agronomist consultar las plantaciones afiliadas y al Administrator acceder al conjunto administrativo. Los endpoints `/health/live` y `/health/ready` pertenecen a la supervisión técnica del proceso.

