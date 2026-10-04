# 5.6. Bounded Context: Field Technical Management

El bounded context **Field Technical Management** registra el trabajo técnico efectuado en campo: visitas, inspecciones —también las capturadas sin conexión—, observaciones e intervenciones agronómicas. `SmartPalm.FieldService` es propietario exclusivo del esquema PostgreSQL `field`. Mantiene proyecciones locales de usuarios, suscripciones, plantaciones, sectores, afiliaciones, alertas y recomendaciones que se actualizan de manera idempotente a partir de eventos de Identity, Crop, Alert y Agronomy. Por tanto, no consulta ni comparte bases de datos externas.

## 5.6.1. Domain Layer

La **Domain Layer** encapsula el ciclo del trabajo de campo y sus reglas. Las raíces de agregado controlan sus propias transiciones de estado; la evidencia pertenece a la inspección; las proyecciones son datos mínimos de otros bounded contexts que permiten validar reglas sin acoplamiento de persistencia.

### 1. FieldVisit

| Campo | Detalle |
|---|---|
| **Nombre** | `FieldVisit` |
| **Categoría** | Aggregate Root |
| **Propósito** | Planificar y controlar el ciclo de una visita técnica a una plantación. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `Id` | `long` | public get, private set | Identificador persistente. |
| `PlantationId`, `AgronomistId` | `long` | public get, private set | Identificadores externos de la plantación y agrónomo responsable. |
| `ScheduledDate`, `ActualDate` | `DateOnly`, `DateOnly?` | public get, private set | Fecha planificada e inicio real. |
| `Status` | `VisitStatus` | public get, private set | Estado de la visita. |
| `Objectives`, `CancellationReason` | `string`, `string?` | public get, private set | Objetivo de la visita y motivo de cancelación. |
| `CreatedAtUtc`, `CompletedAtUtc` | `DateTime`, `DateTime?` | public get, private set | Auditoría de creación y cierre. |

**Métodos**

| Nombre | Parámetros | Retorno | Descripción e invariantes |
|---|---|---|---|
| `FieldVisit` | `plantationId`, `agronomistId`, `scheduledDate`, `objectives` | — | Exige IDs positivos, fecha actual o futura y objetivos no vacíos. |
| `Start` | — | `void` | Solo pasa de `Planned` a `InProgress` y registra la fecha real. |
| `Complete` | `hasInspections` | `void` | Solo completa una visita en progreso que posee al menos una inspección. |
| `Cancel` | `reason` | `void` | Solo cancela una visita planificada y exige un motivo. |

### 2. FieldInspection

| Campo | Detalle |
|---|---|
| **Nombre** | `FieldInspection` |
| **Categoría** | Aggregate Root |
| **Propósito** | Capturar una inspección de un sector, sus observaciones y vínculos con alertas; soporta sincronización offline. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `Id` | `long` | public get, private set | Identificador de la inspección. |
| `ClientReference` | `Guid` | public get, private set | Referencia única generada por el cliente para deduplicar capturas y reintentos. |
| `VisitId`, `SectorId`, `PlantationId`, `AgronomistId` | `long` | public get, private set | Contexto de la inspección. |
| `InspectedAtUtc`, `RegisteredAtUtc` | `DateTime` | public get, private set | Instante observado y registro en el servicio. |
| `SyncStatus` | `SyncStatus` | public get, private set | Estado `Synced` o `PendingSync`. |
| `Observations`, `AlertLinks` | colecciones de solo lectura | public get | Evidencia y enlaces lógicos a AlertService. |

**Métodos**

| Nombre | Parámetros | Retorno | Descripción e invariantes |
|---|---|---|---|
| `FieldInspection` | referencia de cliente, IDs, fecha, `offline` | — | Requiere referencia no vacía e IDs positivos; determina el estado inicial de sincronización. |
| `AddObservation` | descripción, categoría, severidad, fotos, fecha | `void` | Agrega una `FieldObservation` perteneciente a la inspección. |
| `LinkAlert` | `alertId` | `void` | Agrega solo IDs positivos aún no asociados. |
| `MarkSynced` | — | `void` | Marca una captura offline como sincronizada. |

### 3. AgronomicIntervention

| Campo | Detalle |
|---|---|
| **Nombre** | `AgronomicIntervention` |
| **Categoría** | Aggregate Root |
| **Propósito** | Registrar y revisar una acción agronómica trazable hacia una inspección o recomendación. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| `Id`, `PlantationId`, `RegisteredBy` | `long` | public get, private set | Identidad y contexto principal. |
| `SectorId`, `OriginRecommendationId`, `OriginInspectionId` | `long?` | public get, private set | Referencias opcionales de granularidad y trazabilidad. |
| `PerformedBy`, `Description` | `string` | public get, private set | Ejecutante y descripción obligatoria. |
| `Type`, `Status` | `InterventionType`, `InterventionStatus` | public get, private set | Clasificación y resultado de revisión. |
| `ExecutedAtUtc`, `RegisteredAtUtc` | `DateTime` | public get, private set | Tiempos de ejecución y registro. |
| `VerificationNotes`, `VerifiedBy` | `string?`, `long?` | public get, private set | Evidencia de verificación o rechazo. |

**Métodos**

| Nombre | Parámetros | Retorno | Descripción e invariantes |
|---|---|---|---|
| `AgronomicIntervention` | plantación, origen, ejecutante, tipo, descripción y fecha | — | Requiere plantación, registrador, ejecutante y descripción válidos; inicia en `Registered`. |
| `Verify` | `agronomistId`, `notes` | `void` | Solo revisa una intervención aún registrada y exige notas. |
| `Reject` | `agronomistId`, `notes` | `void` | Mantiene las mismas precondiciones y la transición a `Rejected`. |

### 4. Entidades y proyecciones

| Nombre | Categoría | Atributos relevantes | Propósito y relaciones |
|---|---|---|---|
| `FieldObservation` | Entity | `Id`, `InspectionId`, `Description`, `Category`, `Severity`, `PhotoReferencesJson`, `ObservedAtUtc`. | Evidencia de `FieldInspection`; su constructor exige descripción y serializa fotos distintas/no vacías como JSON. |
| `InspectionAlertLink` | Entity | `InspectionId`, `AlertId`. | Enlace compuesto con una alerta externa; no crea una FK entre servicios. |
| `UserProjection` | Projection Entity | `UserId`, `Role`, `HasActiveSubscription`, `UpdatedAtUtc`. | Autoriza usuarios y agrónomos con hechos de Identity. |
| `PlantationProjection` | Projection Entity | `PlantationId`, `PalmGrowerId`, `Name`, `Active`, `UpdatedAtUtc`. | Verifica que una plantación exista y esté activa. |
| `SectorProjection` | Projection Entity | `SectorId`, `PlantationId`, `Name`, `Active`, `UpdatedAtUtc`. | Verifica la pertenencia del sector a la plantación. |
| `AgronomistAffiliationProjection` | Projection Entity | `AffiliationId`, `AgronomistId`, `PlantationId`, `Active`, `UpdatedAtUtc`. | Comprueba afiliación vigente para gestionar campo. |
| `AlertProjection` | Projection Entity | `AlertId`, `PlantationId?`, `SectorId?`, `Status`, `UpdatedAtUtc`. | Permite enlazar una alerta activa y del mismo sector. |
| `RecommendationProjection` | Projection Entity | `RecommendationId`, `AgronomistId`, `SectorId?`, `Content`, `Published`, `UpdatedAtUtc`. | Permite validar una recomendación como origen de intervención. |

### 5. Value objects

| Nombre | Categoría | Valores | Propósito |
|---|---|---|---|
| `VisitStatus` | Enum | `Planned`, `InProgress`, `Completed`, `Cancelled` | Restringe las transiciones de visita. |
| `SyncStatus` | Enum | `Synced`, `PendingSync` | Expresa el estado de captura. |
| `ObservationCategory` | Enum | `Phytosanitary`, `SoilCondition`, `PlantDevelopment`, `Irrigation`, `General` | Clasifica evidencia técnica. |
| `ObservationSeverity` | Enum | `Low`, `Medium`, `High` | Expresa su severidad. |
| `InterventionType` | Enum | `Fertilization`, `PestControl`, `IrrigationAdjustment`, `Pruning`, `SoilAmendment`, `Other` | Tipifica una intervención. |
| `InterventionStatus` | Enum | `Registered`, `Verified`, `Rejected` | Controla el resultado de revisión. |

### 6. Domain services, repositories y Unit of Work

| Nombre | Categoría | Métodos | Propósito |
|---|---|---|---|
| `FieldAccessPolicy` | Domain Service | `EnsureActiveFieldUser`, `EnsureAgronomist`, `EnsurePlantationAccess`. | Exige usuario existente y suscrito, rol `Agronomist` o `Administrator`, plantación activa y afiliación. |
| `InterventionTraceabilityService` | Domain Service | `Validate(intervention, recommendation, inspection)`. | Rechaza recomendaciones no publicadas, sectores incompatibles o una inspección de otra plantación. |
| `IFieldVisitRepository` | Repository port | `FindAsync`, `ListAsync`, `Add`. | Acceso a agenda y agregados de visita. |
| `IFieldInspectionRepository` | Repository port | `FindAsync`, `FindByClientReferenceAsync`, `AnyByVisitAsync`, `ListByPlantationAsync`, `Add`. | Persistencia e idempotencia de inspecciones. |
| `IInterventionRepository` | Repository port | `FindAsync`, listas por plantación/sector/recomendación, `Add`. | Persistencia e historial de intervenciones. |
| `IFieldProjectionRepository` | Repository port | búsquedas y `GetOrCreate*` de proyecciones y afiliaciones. | Puerto para información local recibida por eventos. |
| `IUnitOfWork` | Transaction port | `SaveChangesAsync`, `ExecuteAsync<T>`. | Agrupa estado de negocio y Outbox de forma atómica. |

### 7. Commands, queries y eventos de integración

Los *commands* y *queries* son records que transportan intención o criterios; no contienen reglas de negocio.

| Tipo | Parámetros reales | Propósito |
|---|---|---|
| `PlanVisitCommand` | plantación, agrónomo, fecha, objetivos | Planificar una visita. |
| `StartVisitCommand`, `CompleteVisitCommand` | visita, agrónomo | Iniciar o completar la visita. |
| `CancelVisitCommand` | visita, agrónomo, motivo | Cancelar una visita planificada. |
| `RegisterInspectionCommand` | `ClientReference`, visita, sector, agrónomo, observaciones, fecha, alertas, offline | Registrar una inspección de forma idempotente. |
| `SyncOfflineInspectionsCommand` | visita, agrónomo, lista de inspecciones | Sincronizar evidencia offline en lote. |
| `ObservationInput`, `AddObservationCommand` | datos de evidencia; inspección y observación | Añadir evidencia a una inspección. |
| `LinkInspectionToAlertCommand` | inspección, alerta | Asociar una alerta activa del mismo sector. |
| `RegisterInterventionCommand` | plantación, sector opcional, registrador, ejecutante, tipo, descripción, orígenes, fecha | Registrar una intervención trazable. |
| `VerifyInterventionCommand`, `RejectInterventionCommand` | intervención, agrónomo, notas | Decidir la revisión. |
| `GetVisitsByAgronomistQuery`, `GetVisitByIdQuery` | filtros de agenda; visita | Consultar agenda y detalle. |
| `GetInspectionByIdQuery`, `GetInspectionsByPlantationQuery` | inspección; plantación, sector y fechas | Consultar evidencia de campo. |
| `GetInterventionByIdQuery`, `GetInterventionsByPlantationQuery`, `GetInterventionsBySectorQuery`, `GetInterventionsByRecommendationQuery` | IDs y filtros | Recuperar historial de intervención. |
| `GetTraceabilityChainQuery` | plantación | Expresar una consulta de trazabilidad por plantación. |

| Evento | Campos principales | Rol |
|---|---|---|
| `FieldVisitPlannedIntegrationEvent`, `FieldVisitCompletedIntegrationEvent` | visita, plantación, agrónomo, hora; fecha planificada para el primero | Hechos publicados del ciclo de visita. |
| `FieldInspectionRegisteredIntegrationEvent` | inspección, `ClientReference`, visita, plantación, sector, agrónomo, fechas | Hecho publicado al registrar evidencia. |
| `AgronomicInterventionRegisteredIntegrationEvent` | intervención, plantación/sector, registrador, orígenes, tipo y ejecución | Hecho publicado de trazabilidad. |
| `AgronomicInterventionReviewedIntegrationEvent` | intervención, estado, agrónomo, hora | Resultado publicado de la revisión. |
| `UserCreatedIntegrationEvent`; `SubscriptionCreated/Activated/CancelledIntegrationEvent` | usuario, rol/estado y hora | Eventos consumidos para `UserProjection`. |
| `PlantationCreatedIntegrationEvent`; `SectorAssigned/RemovedIntegrationEvent`; `AgronomistAffiliated/DetachedIntegrationEvent` | IDs, datos de contexto y hora | Eventos consumidos desde Crop para proyecciones y acceso. |
| `AlertTriggeredIntegrationEvent`, `AlertAcknowledgedIntegrationEvent` | alerta, contexto de cultivo/lectura o usuario, hora | Eventos consumidos desde Alert. |
| `RecommendationPublishedIntegrationEvent` | recomendación, agrónomo, sector, contenido, versión, hora | Evento consumido desde Agronomy para trazabilidad. |

