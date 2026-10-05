
## 5.3.2. Interface Layer

La **Interface Layer** recibe solicitudes HTTP autenticadas, obtiene la identidad y el rol desde JWT, convierte recursos en commands o queries y retorna recursos de transporte. Los controllers no exponen agregados ni entidades EF Core.

##### 1. AlertsController

| Campo | Detalle |
|---|---|
| **Nombre** | AlertsController |
| **Categoría** | Controller REST |
| **Ruta base** | `api/v1/alerts` |
| **Propósito** | Listar alertas visibles y registrar su reconocimiento. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `commandService` | `AlertCommandService` | private readonly (primary constructor) | Coordina reconocimientos. |
| `queryService` | `AlertQueryService` | private readonly (primary constructor) | Recupera alertas por usuario y rol. |

**Métodos**

| Nombre | Verbo HTTP | Ruta | Autorización | Tipo de retorno | Descripción |
|---|---|---|---|---|---|
| `GetAlerts` | GET | `/` | `Administrator`, `PalmGrower`, `Agronomist` | `Task<ActionResult<IReadOnlyList<AlertResource>>>` | Crea `GetAlertsByUserIdQuery` desde JWT y devuelve alertas permitidas. |
| `AcknowledgeAlert` | PATCH | `/{alertId}` | `Administrator`, `PalmGrower`, `Agronomist` | `Task<IActionResult>` | Crea `AcknowledgeAlertCommand` y retorna `204 No Content`. |

---

##### 2. AdminAlertsController

| Campo | Detalle |
|---|---|
| **Nombre** | AdminAlertsController |
| **Categoría** | Controller REST administrativo |
| **Ruta base** | `api/v1/admin/alerts` |
| **Propósito** | Consultar globalmente las alertas para administración. |

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `queryService` | `AlertQueryService` | private readonly (primary constructor) | Ejecuta la consulta administrativa. |

| Nombre | Verbo HTTP | Ruta | Autorización | Tipo de retorno | Descripción |
|---|---|---|---|---|---|
| `ListAlerts` | GET | `/` | `Administrator` | `Task<ActionResult<IReadOnlyList<AlertResource>>>` | Ejecuta `GetAllAlertsQuery` y transforma sus resultados. |

---

##### 3. UserAlertSettingsController

| Campo | Detalle |
|---|---|
| **Nombre** | UserAlertSettingsController |
| **Categoría** | Controller REST |
| **Ruta base** | `api/v1/alert-settings` |
| **Propósito** | Consultar y actualizar preferencias de silencio por sensor. |

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `commandService`, `queryService` | `AlertCommandService`, `AlertQueryService` | private readonly (primary constructor) | Coordinan mutaciones y lecturas de preferencias. |

| Nombre | Verbo HTTP | Ruta | Autorización | Tipo de retorno | Descripción |
|---|---|---|---|---|---|
| `GetUserAlertSettings` | GET | `/` | Usuario autenticado | `Task<ActionResult<IReadOnlyList<UserAlertSettingResource>>>` | Lista preferencias del usuario de JWT. |
| `GetUserAlertSettingBySensorType` | GET | `/{sensorType}` | Usuario autenticado | `Task<ActionResult<UserAlertSettingResource>>` | Retorna `400` por sensor inválido, `404` si no existe o `200 OK`. |
| `UpdateUserAlertSetting` | PUT | `/{sensorType}` | Usuario autenticado | `Task<ActionResult<UserAlertSettingResource>>` | Valida el sensor, transforma el recurso y devuelve la preferencia actualizada. |

---

##### 4. Resources, assemblers y claims

| Nombre | Categoría | Campos o métodos | Propósito |
|---|---|---|---|
| `AlertResource` | Response record | `id`, `sensorType`, `message`, `level`, `status`, `timestamp` | Contrato HTTP de una alerta. |
| `UserAlertSettingResource` | Response record | `sensorType`, `isMuted` | Contrato HTTP de una preferencia. |
| `UpdateUserAlertSettingResource` | Request record | `isMuted` | Cuerpo de actualización. |
| `AlertResourceAssemblers` | Static assembler | `ToResource(AlertResponse)`, `ToResource(UserAlertSettingResponse)` | Convierte DTOs de Application en recursos REST. |
| `ClaimsPrincipalExtensions` | Internal static helper | `RequiredUserId`, `RequiredRole` | Obtiene `sid`/`sub` y `role`; rechaza claims ausentes o inválidos. |

Los endpoints `/health/live` y `/health/ready` son puntos de supervisión técnica, no capacidades HTTP del dominio.
