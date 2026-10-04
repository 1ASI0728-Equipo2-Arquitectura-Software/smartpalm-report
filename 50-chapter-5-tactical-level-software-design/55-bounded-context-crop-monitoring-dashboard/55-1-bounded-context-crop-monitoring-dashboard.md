## 5.5. Bounded Context: Crop Monitoring Dashboard.

El bounded context **Crop Monitoring Dashboard** es el read-model del sistema: consolida salud por zona y plantación, series temporales, alertas (BC-03), recomendaciones publicadas (BC-04) y reportes técnicos del agrónomo en un solo dashboard web y móvil. No produce telemetría ni decide manejo: muestra lo que otros bounded contexts ya validaron. Sin esta consolidación, cada rol tendría que armar su propia vista cruzando microservicios. Por eso se despliega como **microservicio independiente** con base de datos propia para snapshots, vistas y reportes, mientras las series crudas se consultan en vivo a BC-02 sin duplicarse.

Esta sección detalla su diseño táctico en el orden en que se construye y se lee: primero el modelo de dominio con sus reglas (5.5.1), luego la superficie HTTP que lo expone (5.5.2), la orquestación de los flujos (5.5.3), la materialización en persistencia e integración (5.5.4), y finalmente las vistas de arquitectura que lo verifican visualmente (5.5.6 y 5.5.7). Las capacidades cubiertas son seis: salud por zona/plantación con worst-wins, series con tendencias y resumen estadístico, feed de alertas, feed de recomendaciones, reportes técnicos con ciclo borrador→publicado y exportación, y comparación y priorización de zonas. El refresh entra por eventos (lotes de BC-02, publicadas de BC-04); las alertas se consultan por ACL a BC-03, cuyos eventos aún no existen y no se inventan.

### 5.5.1. Domain Layer.

La Domain Layer concentra el núcleo del dominio en dos grupos: salud (snapshots por zona, resúmenes por parámetro, vistas por plantación, evaluación worst-wins y ranking) y series/reportes (series transitorias, reportes técnicos con secciones, cálculo de tendencias). Además define los repositorios, los servicios de dominio, y los commands, queries y eventos que estructuran las operaciones.

Cada agregado gobierna su consistencia: el snapshot con sus resúmenes, la vista con sus conteos, el reporte con sus secciones. Las series temporales son vistas transitorias sin persistencia: se calculan en vivo desde BC-02 para no duplicar la telemetría cruda. El diccionario se lee ficha por ficha y todo lo que aparece en los diagramas de 5.5.6 y 5.5.7 sale de aquí, sin elementos de más. `SensorType` y `MeasureUnit` no se redefinen: se referencian los shared kernels de 5.1 y 5.2.

##### 1. CropHealthSnapshot

| Campo | Detalle |
|---|---|
| **Nombre** | CropHealthSnapshot |
| **Categoría** | Entity / Aggregate Root |
| **Propósito** | Captura consolidada del estado de salud de una zona en un momento dado, con regla worst-wins ante conflicto entre parámetros. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| Id | Guid | private | Identificador único. |
| ZoneId | Guid | private | Zona evaluada. Referencia lógica a BC-06, sin FK. |
| PlantationId | Guid | private | Plantación de la zona. Referencia lógica a BC-06, sin FK. |
| OverallStatus | CropStatus | private | Estado consolidado: el peor individual prevalece. |
| DominantRiskFactor | string | private | Parámetro que determina el estado general. |
| EvaluatedAt | DateTime | private | Fecha de generación. |
| ActiveAlertCount | int | private | Alertas activas en la zona al evaluar. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Evaluate | void | public | Recalcula el estado con worst-wins. |
| IsCritical | bool | public | Indica si la zona está en estado crítico. |
| GetDominantRisk | string | public | Retorna el parámetro dominante. |

---

##### 2. ParameterSummary

| Campo | Detalle |
|---|---|
| **Nombre** | ParameterSummary |
| **Categoría** | Value Object (inmutable, parte del snapshot) |
| **Propósito** | Resumen del estado de una variable individual dentro de un snapshot. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| SensorType | SensorType | private | Variable medida (shared kernel 5.1). |
| CurrentValue | double | private | Último valor registrado. |
| MeasureUnit | MeasureUnit | private | Unidad (shared kernel 5.2). |
| Status | ParameterStatus | private | Normal / Warning / Critical. |
| ThresholdMin | double | private | Mínimo vigente al evaluar. |
| ThresholdMax | double | private | Máximo vigente al evaluar. |

---

##### 3. CropStatus

| Campo | Detalle |
|---|---|
| **Nombre** | CropStatus |
| **Categoría** | Enumeration |
| **Propósito** | Estado consolidado de zona o plantación. |

**Valores**

| Nombre | Descripción |
|---|---|
| Optimal | Todas las variables en rango normal. |
| AtRisk | Al menos una en Warning, ninguna en Critical. |
| Critical | Al menos una en Critical. |

---

##### 4. ParameterStatus

| Campo | Detalle |
|---|---|
| **Nombre** | ParameterStatus |
| **Categoría** | Enumeration |
| **Propósito** | Estado individual de un parámetro. |

**Valores**

| Nombre | Descripción |
|---|---|
| Normal | Valor dentro del rango aceptable. |
| Warning | Valor cercano a los límites. |
| Critical | Valor fuera del rango aceptable. |

---

##### 5. PlantationOverview

| Campo | Detalle |
|---|---|
| **Nombre** | PlantationOverview |
| **Categoría** | Entity / Aggregate Root |
| **Propósito** | Vista consolidada de una plantación con conteos por estado y última actualización. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| Id | Guid | private | Identificador único. |
| PlantationId | Guid | private | Plantación. Referencia lógica a BC-06, sin FK. |
| TotalZones | int | private | Zonas de monitoreo. |
| CriticalZones | int | private | Zonas en Critical. |
| AtRiskZones | int | private | Zonas en AtRisk. |
| OptimalZones | int | private | Zonas en Optimal. |
| OverallStatus | CropStatus | private | Worst-wins entre zonas. |
| LastUpdatedAt | DateTime | private | Última actualización. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Consolidate | void | public | Recalcula desde los snapshots de sus zonas. |
| GetZonesByPriority | List\<CropHealthSnapshot\> | public | Zonas por criticidad descendente. |
| HasDataGap | bool | public | True si alguna zona supera 24h sin actualizar. |

---

##### 6. SensorTimeSeries

| Campo | Detalle |
|---|---|
| **Nombre** | SensorTimeSeries |
| **Categoría** | Vista transitoria (SIN persistencia ni repositorio) |
| **Propósito** | Historial de una variable en una zona durante un período, calculado en vivo desde BC-02. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| ZoneId | Guid | private | Zona consultada. |
| SensorType | SensorType | private | Variable (shared kernel 5.1). |
| From | DateTime | private | Inicio del rango. |
| To | DateTime | private | Fin del rango. |
| TrendDirection | TrendDirection | private | Rising / Stable / Falling. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| CalculateTrend | TrendDirection | public | Regresión lineal; <3 puntos → Stable. |
| GetAverage | double | public | Promedio del período. |
| GetMax | double | public | Máximo del período. |
| GetMin | double | public | Mínimo del período. |
| HasAnomalies | bool | public | True si hay valores fuera de rango. |

---

##### 7. TimeSeriesDataPoint

| Campo | Detalle |
|---|---|
| **Nombre** | TimeSeriesDataPoint |
| **Categoría** | Value Object (inmutable) |
| **Propósito** | Punto individual de una serie temporal. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| Timestamp | DateTime | private | Momento de la lectura. |
| Value | double | private | Valor registrado. |
| Status | ParameterStatus | private | Estado respecto a umbrales. |

---

##### 8. TrendDirection

| Campo | Detalle |
|---|---|
| **Nombre** | TrendDirection |
| **Categoría** | Enumeration |
| **Propósito** | Dirección de la tendencia. |

**Valores**

| Nombre | Descripción |
|---|---|
| Rising | Tendencia ascendente significativa. |
| Stable | Estable o datos insuficientes. |
| Falling | Tendencia descendente significativa. |

---

##### 9. TechnicalReport

| Campo | Detalle |
|---|---|
| **Nombre** | TechnicalReport |
| **Categoría** | Entity / Aggregate Root |
| **Propósito** | Reporte técnico del agrónomo con ciclo borrador→publicado y trazabilidad a snapshots. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| Id | Guid | private | Identificador único. |
| PlantationId | Guid | private | Plantación evaluada. Referencia lógica a BC-06. |
| AuthorId | Guid | private | Agrónomo autor. Referencia lógica a BC-07. |
| Title | string | private | Título del reporte. |
| Summary | string | private | Resumen ejecutivo. |
| Status | ReportStatus | private | Draft / Published. |
| GeneratedAt | DateTime | private | Fecha del borrador. |
| PublishedAt | DateTime | private | Fecha de publicación. Nula en borrador. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Create | void | public | Alta en Draft. |
| AddSection | void | public | Agrega sección; solo en Draft. |
| Publish | void | public | Draft → Published; registra `PublishedAt`. |
| IsDraft | bool | public | Indica si está en borrador. |
| IsPublished | bool | public | Indica si está publicado. |

---

##### 10. ReportSection

| Campo | Detalle |
|---|---|
| **Nombre** | ReportSection |
| **Categoría** | Value Object (parte del reporte, con posición) |
| **Propósito** | Sección individual ordenada dentro de un reporte. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| Title | string | private | Título de la sección. |
| Content | string | private | Contenido textual. |
| SectionType | SectionType | private | MonitoringSummary / AlertReview / Recommendations / Observations. |
| Position | int | private | Orden dentro del reporte. |

---

##### 11. ReportStatus

| Campo | Detalle |
|---|---|
| **Nombre** | ReportStatus |
| **Categoría** | Enumeration |
| **Propósito** | Estado del reporte. |

**Valores**

| Nombre | Descripción |
|---|---|
| Draft | Editable, no visible. |
| Published | Inmutable y visible. |

---

##### 12. SectionType

| Campo | Detalle |
|---|---|
| **Nombre** | SectionType |
| **Categoría** | Enumeration |
| **Propósito** | Tipos de sección. |

**Valores**

| Nombre | Descripción |
|---|---|
| MonitoringSummary | Resumen de monitoreo. |
| AlertReview | Revisión de alertas del período. |
| Recommendations | Recomendaciones agronómicas. |
| Observations | Observaciones de campo. |

---

##### 13. Repositories

| Campo | Detalle |
|---|---|
| **Nombre** | ICropHealthSnapshotRepository / IPlantationOverviewRepository / ITechnicalReportRepository |
| **Categoría** | Repository (interfaces, contratos de agregados) |
| **Propósito** | Persistencia en la base propia. Sin repositorio de series (vista transitoria vía ACL a BC-02). |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| AddOrUpdate (snapshots) | Task | public | Inserta o actualiza snapshot con sus resúmenes. |
| FindByZone | Task\<CropHealthSnapshot?\> | public | Último snapshot de una zona. |
| FindLatestByPlantation | Task\<IEnumerable\<CropHealthSnapshot\>\> | public | Últimos snapshots por plantación. |
| FindByStatus | Task\<IEnumerable\<CropHealthSnapshot\>\> | public | Por estado y rango de fechas. |
| AddOrUpdate (overviews) | Task | public | Inserta o actualiza vista con conteos. |
| FindByPlantation (overview) | Task\<PlantationOverview?\> | public | Vista vigente de una plantación. |
| FindByUser | Task\<IEnumerable\<PlantationOverview\>\> | public | Vistas de plantaciones asignadas al usuario. |
| GetLastUpdate | Task\<DateTime\> | public | Última actualización de una plantación. |
| AddAsync (reports) | Task | public | Agrega un reporte con secciones. |
| Update (reports) | void | public | Marca el reporte como modificado. |
| FindById (reports) | Task\<TechnicalReport?\> | public | Por `Id`. |
| FindByPlantation (reports) | Task\<IEnumerable\<TechnicalReport\>\> | public | Por plantación con filtro opcional por estado. |

---

##### 14. Domain Services

| Campo | Detalle |
|---|---|
| **Nombre** | ICropHealthEvaluationService / IZonePriorityRankingService / ITrendCalculationService (+ implementaciones) |
| **Categoría** | Domain Service (interfaces + implementaciones) |
| **Propósito** | Worst-wins, ranking por criticidad y regresión de tendencias, sin dependencias de infraestructura. |

**Métodos**

| Nombre | Descripción |
|---|---|
| Evaluate | Aplica worst-wins sobre los resúmenes del snapshot. |
| RankByCriticality | Ordena zonas: Critical, AtRisk, Optimal; dentro de cada grupo por recencia. |
| Calculate | Regresión lineal sobre data points; <3 puntos → Stable. |

---

##### 15. Commands

Objetos inmutables que encapsulan intención de cambio. Todos viajan con `CorrelationId` para trazabilidad e idempotencia.

| Nombre | Parámetros | Descripción |
|---|---|---|
| ComputeZoneSnapshotsCommand | BatchId, EdgeMac, CorrelationId | Recomputa snapshots de las zonas del lote. |
| RefreshPlantationOverviewCommand | PlantationId, CorrelationId | Reconsolida la vista de una plantación. |
| GenerateReportDraftCommand | PlantationId, AuthorId, Title, From, To, CorrelationId | Borrador con snapshots y alertas del período. |
| AddReportSectionCommand | ReportId, Title, Content, SectionType, CorrelationId | Sección solo en Draft. |
| PublishReportCommand | ReportId, AuthorId, CorrelationId | Draft → Published. |
| ExportReportCommand | ReportId, Format (PDF\|CSV), CorrelationId | Exportación descargable. |

---

##### 16. Queries

Objetos inmutables de solo lectura, con filtros opcionales que evitan la combinatoria de métodos.

| Nombre | Parámetros | Descripción |
|---|---|---|
| HealthQuery | PlantationId, ZoneId (opcional) | Salud de plantación o detalle de zona. |
| PriorityZonesQuery | PlantationId | Zonas por criticidad. |
| CompareZonesQuery | PlantationId, ZoneIds | Comparación entre zonas. |
| OverviewsQuery | UserId | Vistas de plantaciones del usuario. |
| PlantationOverviewQuery | PlantationId | Detalle de una vista. |
| LastUpdateQuery | PlantationId | Última actualización y brecha de datos. |
| SeriesQuery | ZoneId, SensorType, From, To | Serie temporal. |
| TrendQuery | ZoneId, SensorType, From, To | Tendencia calculada. |
| SeriesSummaryQuery | ZoneId, SensorType, From, To | Promedio, máximo, mínimo, anomalías. |
| ZoneVariablesQuery | ZoneId | Variables disponibles con valores actuales. |
| ReportByIdQuery | ReportId | Detalle de un reporte. |
| ReportsByPlantationQuery | PlantationId, Status (opcional) | Reportes con filtro por estado. |
| ActiveAlertsQuery | PlantationId | Alertas activas (vía BC-03). |
| AlertHistoryQuery | PlantationId, ZoneId, Severity, From, To (opcionales) | Historial de alertas (vía BC-03). |
| RecsByPlantationQuery | PlantationId | Publicadas (vía BC-04). |
| RecDetailQuery | RecommendationId | Detalle de una publicada (vía BC-04). |

---

##### 17. Eventos de integración

BC-05 consume tres eventos v1 existentes y publica uno propio, todos sobre RabbitMQ con entrega al menos una vez; los consumidores son idempotentes y existe dead-letter queue. Las alertas NO llegan por eventos (BC-03 aún no los define): se consultan por ACL.

Consumidos:

| Nombre | Versión | Cuándo | Contenido mínimo |
|---|---|---|---|
| ReadingsBatchStored | v1 (BC-02) | Lote reconciliado. | batchId, edgeMac, storedCount, correlationId |
| RecommendationPublished | v1 (BC-04) | Publicación confirmada. | recommendationId, plantationId, deviceMac, sensorType, content, publishedAt, correlationId |
| InterventionRegistered | v1 (BC-04) | Intervención registrada. | interventionId, recommendationId, performedBy, executionDate, correlationId |

Publicado:

| Nombre | Versión | Cuándo | Contenido mínimo |
|---|---|---|---|
| ReportPublished | v1 | Reporte publicado. | reportId, plantationId, status, publishedAt, correlationId |

---

### 5.5.2. Interface Layer.

Punto de entrada HTTP del microservicio. Todo el tráfico pasa por el API Gateway con JWT según rol; todos los endpoints requieren autenticación. Seis controllers delgados que validan forma, convierten con assemblers y delegan en Application.

##### 1. CropHealthController — `api/v1/monitoring/health` (JWT-User)

| Nombre | Verbo HTTP | Ruta | Descripción |
|---|---|---|---|
| GetPlantationHealth | GET | `/plantations/{plantationId}` | Salud consolidada (zona opcional por query). |
| GetPriorityZones | GET | `/plantations/{plantationId}/priority` | Zonas por criticidad. |
| CompareZones | GET | `/plantations/{plantationId}/compare?zoneIds=` | Comparación entre zonas. |

##### 2. PlantationOverviewController — `api/v1/monitoring/overviews` (JWT-User)

| Nombre | Verbo HTTP | Ruta | Descripción |
|---|---|---|---|
| GetMyOverviews | GET | `/` | Vistas del usuario autenticado. |
| GetPlantationOverview | GET | `/{plantationId}` | Detalle con conteos. |
| GetLastUpdate | GET | `/{plantationId}/last-update` | Última actualización y brecha. |

##### 3. TimeSeriesController — `api/v1/monitoring/series` (JWT-User)

| Nombre | Verbo HTTP | Ruta | Descripción |
|---|---|---|---|
| GetSeries | GET | `/zones/{zoneId}` | Serie con `sensorType`, `from`, `to`. |
| GetTrend | GET | `/zones/{zoneId}/trend` | Tendencia del período. |
| GetSeriesSummary | GET | `/zones/{zoneId}/summary` | Estadísticas y anomalías. |
| GetZoneVariables | GET | `/zones/{zoneId}/variables` | Variables disponibles. |

##### 4. TechnicalReportsController — `api/v1/monitoring/reports`

| Nombre | Verbo HTTP | Ruta | Auth | Descripción |
|---|---|---|---|---|
| GenerateDraft | POST | `/` | JWT-Agronomist | Borrador con datos del período. |
| GetReports | GET | `/` | JWT-User | Por `plantationId`, filtro `status`. |
| GetReportById | GET | `/{reportId}` | JWT-User | Detalle completo. |
| AddSection | POST | `/{reportId}/sections` | JWT-Agronomist | Solo en Draft. |
| PublishReport | POST | `/{reportId}/publish` | JWT-Agronomist | Draft → Published. |
| ExportReport | GET | `/{reportId}/export?format=` | JWT-User | PDF o CSV descargable. |

##### 5. AlertsFeedController — `api/v1/monitoring/alerts` (JWT-User, vía BC-03)

| Nombre | Verbo HTTP | Ruta | Descripción |
|---|---|---|---|
| GetActiveAlerts | GET | `/` | Activas por `plantationId`. |
| GetAlertHistory | GET | `/history` | Con filtros zona, severidad, rango. |

##### 6. RecommendationsFeedController — `api/v1/monitoring/recommendations` (JWT-User, vía BC-04)

| Nombre | Verbo HTTP | Ruta | Descripción |
|---|---|---|---|
| GetPublishedFeed | GET | `/` | Publicadas por `plantationId`. |
| GetRecommendationDetail | GET | `/{recommendationId}` | Detalle de una publicada. |

##### 7. Resources y assemblers

Resources principales: `HealthViewResource`, `OverviewViewResource`, `SeriesViewResource`, `TrendViewResource`, `ReportDraftResource`, `SectionResource`, `ReportViewResource`, `AlertFeedViewResource`, `RecommendationFeedViewResource`. Cada query/command principal tiene su assembler `*FromResourceAssembler` en ambas direcciones; el dominio nunca conoce detalles web.

### 5.5.3. Application Layer.

Orquesta los flujos de lectura y el ciclo de reportes: recibe commands, queries y eventos, delega en dominio, persiste snapshots/vistas/reportes mediante Unit of Work, consulta telemetría y feeds externos por ACL, y publica `ReportPublished` con Outbox transaccional.

La lectura nunca muta: los únicos writes son snapshots/vistas recomputados y el ciclo de reportes. Cada mutación confirmada deja su evento en el Outbox dentro de la misma transacción. Los feeds externos degradan con gracia: si BC-03/BC-04 no responden, el dashboard muestra sus secciones como no disponibles sin romper el resto.

##### 1. SnapshotComputationService

| Campo | Detalle |
|---|---|
| **Nombre** | SnapshotComputationService |
| **Categoría** | Command Service |
| **Propósito** | Recomputar snapshots y vistas ante lotes o a demanda. |
| **Atributos** | `uow: IUnitOfWork`, `snapshotRepository`, `overviewRepository`, `evaluation`, `ranking`, `readingsClient`, `outbox: IOutboxWriter`. |

**Métodos (Handle)**

| Nombre | Descripción |
|---|---|
| Handle(ComputeZoneSnapshotsCommand) | Lee lecturas del lote vía ACL (BC-02), evalúa worst-wins por zona y persiste snapshots. Idempotente por `batchId`. |
| Handle(RefreshPlantationOverviewCommand) | Reconsolida conteos y `lastUpdatedAt` desde los últimos snapshots. |

##### 2. ReportCommandService

| Campo | Detalle |
|---|---|
| **Nombre** | ReportCommandService |
| **Categoría** | Command Service |
| **Propósito** | Ciclo de reportes y exportación. |
| **Atributos** | `uow: IUnitOfWork`, `reportRepository`, `snapshotRepository`, `exportService`, `outbox: IOutboxWriter`. |

**Métodos (Handle)**

| Nombre | Descripción |
|---|---|
| Handle(GenerateReportDraftCommand) | Crea el borrador con snapshots y alertas del período y persiste. |
| Handle(AddReportSectionCommand) | Agrega sección; solo en Draft (`409` en otro estado). |
| Handle(PublishReportCommand) | Draft → Published; persiste y publica `ReportPublished`. |
| Handle(ExportReportCommand) | Genera PDF o CSV según `format`. |

##### 3. Query Services

| Nombre | Queries que atiende | Fuentes |
|---|---|---|
| HealthQueryService | Health, PriorityZones, CompareZones | Repos de snapshots + ranking. |
| OverviewQueryService | Overviews, PlantationOverview, LastUpdate | Repo de vistas. |
| TimeSeriesQueryService | Series, Trend, SeriesSummary, ZoneVariables | ACL lecturas (BC-02) + cálculo de tendencias. |
| ReportQueryService | ReportById, ReportsByPlantation | Repo de reportes. |
| AlertFeedQueryService | ActiveAlerts, AlertHistory | ACL alertas (BC-03). |
| RecommendationFeedQueryService | RecsByPlantation, RecDetail | ACL publicadas (BC-04). |

##### 4. Handlers de eventos (RabbitMQ)

| Nombre | Consume | Propósito |
|---|---|---|
| BatchStoredHandler | `ReadingsBatchStored` (BC-02) | Convierte en `ComputeZoneSnapshotsCommand` + `RefreshPlantationOverviewCommand`. Idempotente por `batchId`. |
| RecommendationPublishedHandler | `RecommendationPublished` (BC-04) | Invalida/actualiza el feed de publicadas. Idempotente por `correlationId`. |
| InterventionRegisteredHandler | `InterventionRegistered` (BC-04) | Actualiza el feed con la acción de campo. Idempotente por `correlationId`. |

### 5.5.4. Infrastructure Layer.

Materialización del microservicio con persistencia propia, mensajería para un solo evento publicado e integración por ACL al resto: base de datos exclusiva con migraciones propias y cero tablas compartidas, sin telemetría cruda duplicada.

La base propia guarda lo que el dashboard congela (snapshots, vistas, reportes) y nada de lo que otros BCs ya guardan (lecturas, alertas, recomendaciones se consultan en vivo). Las referencias a zonas, plantaciones y autores son Guid lógicos sin FK porque viven en otras bases. Los ACL aíslan al dominio de cambios en los contratos externos, con degradación graciosa ante indisponibilidad.

##### 1. MonitoringDbContext

| Campo | Detalle |
|---|---|
| **Nombre** | MonitoringDbContext |
| **Categoría** | DbContext propio del microservicio (PostgreSQL, `DATABASE_URL` exclusiva) |
| **Propósito** | Acceso a datos del BC-05. El propio contexto actúa como Unit of Work (`SaveChanges` transaccional junto al Outbox). |
| **Tablas** | `crop_health_snapshots`, `parameter_summaries` (UK snapshot+tipo), `plantation_overviews` (UK plantación), `plantation_overview_snapshots` (join), `technical_reports`, `report_sections`, `report_snapshot_references`, `outbox_messages`. snake_case. |

##### 2. Repositories (EF Core)

`CropHealthSnapshotRepository`, `PlantationOverviewRepository` y `TechnicalReportRepository` sobre el contexto propio. Sin dependencias de acceso a datos fuera del servicio y sin repositorio de series (vista transitoria).

##### 3. RabbitMqEventPublisher + OutboxRelay

| Campo | Detalle |
|---|---|
| **Nombre** | RabbitMqEventPublisher / OutboxRelay |
| **Categoría** | Messaging (publisher + relay) |
| **Propósito** | Publicar `ReportPublished` versionado (exchange por tipo, dead-letter queue). El relay drena `outbox_messages` y confirma la publicación. |

##### 4. ACL Query Clients (HTTP)

| Nombre | Contra | Propósito |
|---|---|---|
| ReadingsQueryClient | BC-02 | Lecturas por gateway/dispositivo/rango para snapshots y series. Contrato existente. |
| AlertsQueryClient | BC-03 | Activas e historial con degradación graciosa. Contrato TBD con rama 53. |
| RecommendationsQueryClient | BC-04 | Publicadas y detalle con filtro Published. Contrato existente. |

##### 5. ReportExportService

| Campo | Detalle |
|---|---|
| **Nombre** | ReportExportService |
| **Categoría** | Technical Service (infraestructura) |
| **Propósito** | Generar PDF (con secciones y datos referenciados) y CSV (tabulares) a partir del reporte almacenado. |
