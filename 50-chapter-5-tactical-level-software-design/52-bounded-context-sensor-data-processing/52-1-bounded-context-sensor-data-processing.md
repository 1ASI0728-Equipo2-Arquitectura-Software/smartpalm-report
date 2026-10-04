## 5.2. Bounded Context: Sensor Data Processing.

El bounded context **Sensor Data Processing** recibe la telemetría que BC-01 sincroniza del campo, la persiste como lecturas inmutables, evalúa cada lectura contra umbrales agronómicos y publica los excesos: es el puente entre la ingesta (BC-01) y las alertas y el monitoreo (BC-03, BC-05). Sin lecturas persistidas y evaluadas no hay alertas que disparar ni historial que mostrar. Por eso se despliega como **microservicio independiente** con base de datos propia, capaz de escalar al ritmo de la ingesta sin arrastrar al resto de la solución.

Esta sección detalla su diseño táctico en el orden en que se construye y se lee: primero el modelo de dominio con sus reglas (5.2.1), luego la superficie HTTP que lo expone (5.2.2), la orquestación de los flujos (5.2.3), la materialización en persistencia y mensajería (5.2.4), y finalmente las vistas de arquitectura que lo verifican visualmente (5.2.6 y 5.2.7). Las capacidades cubiertas son cinco: persistir lecturas sincronizadas, evaluar umbrales por lectura, gestionar umbrales con valores por defecto, consultar historial con filtros y paginado, y propagar cambios de umbral al edge. La ingesta entra exclusivamente por eventos desde BC-01: este bounded context no expone ningún endpoint de escritura de lecturas, porque la idempotencia del lote vive en BC-01 y un segundo punto de entrada la duplicaría y partiría la trazabilidad.

### 5.2.1. Domain Layer.

La Domain Layer concentra el núcleo del dominio: el agregado `SensorReading`, la entidad `AgronomicThreshold`, el enum de unidades, las interfaces de repositorio y de servicios, las factories de creación, además de los commands, queries y eventos de integración que estructuran las operaciones del bounded context.

El agregado se delimita por lectura: cada `SensorReading` es una unidad inmutable de consistencia identificada por `readingId`, de modo que reprocesar un evento jamás duplica datos. Los umbrales viven por dispositivo y tipo de sensor con versionado explícito, para que el edge siempre evalúe con la última versión válida. El diccionario se lee ficha por ficha —categoría, propósito, atributos y métodos— y todo lo que aparece en los diagramas de 5.2.6 y 5.2.7 sale de aquí, sin elementos de más. `SensorType` no se redefine: se referencia el shared kernel de 5.1 con sus 10 valores.

##### 1. SensorReading

| Campo | Detalle |
|---|---|
| **Nombre** | SensorReading |
| **Categoría** | Entity / Aggregate Root |
| **Propósito** | Lectura inmutable capturada por un sensor. Unidad de consistencia identificada por `readingId` para consumo idempotente. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| Id | Guid | private | Identificador único, generable offline sin coordinación. |
| EdgeDeviceMac | string | private | MAC del gateway que retransmitió la lectura. |
| IotDeviceMac | string | private | MAC del nodo que generó la lectura. |
| SensorType | SensorType | private | Tipo de variable medida (shared kernel 5.1). |
| Value | double | private | Valor numérico capturado. |
| MeasureUnit | MeasureUnit | private | Unidad asignada por factory según el tipo. |
| MeasuredAt | DateTime | private | Fecha de captura en campo. |
| ReceivedAt | DateTime | private | Fecha de recepción en el microservicio. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Record | void | public | Alta de la lectura con unidad resuelta por factory. |
| BelongsTo | bool | public | Verifica pertenencia a un lote por `batchId`. |

---

##### 2. AgronomicThreshold

| Campo | Detalle |
|---|---|
| **Nombre** | AgronomicThreshold |
| **Categoría** | Entity (por dispositivo y tipo de sensor) |
| **Propósito** | Rango permitido de una variable para un nodo. Versionado para propagación al edge. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| Id | Guid | private | Identificador único. |
| EdgeDeviceMac | string | private | MAC del gateway del nodo. |
| IotDeviceMac | string | private | MAC del nodo asociado. |
| SensorType | SensorType | private | Variable evaluada (shared kernel 5.1). |
| MinValue | double | private | Mínimo permitido. |
| MaxValue | double | private | Máximo permitido. |
| Description | string | private | Descripción opcional. |
| Version | int | private | Versión vigente; cada `Update` la incrementa. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| IsExceededBy | bool | public | Determina si un valor sale del rango. |
| IsSet | bool | public | Determina si el umbral tiene valores definidos (min != max). |
| Update | bool | public | Actualiza min, max y/o description; incrementa `Version`. Retorna true si hubo cambios. |

---

##### 3. MeasureUnit

| Campo | Detalle |
|---|---|
| **Nombre** | MeasureUnit |
| **Categoría** | Enumeration |
| **Propósito** | Unidades de medida de las lecturas. |

**Valores**

| Nombre | Descripción |
|---|---|
| Percent | Porcentaje (humedad y similares). |
| Centimeter | Centímetros. |
| Meter | Metros. |
| Unknown | Unidad no determinada para el tipo. |

---

##### 4. SensorType

| Campo | Detalle |
|---|---|
| **Nombre** | SensorType |
| **Categoría** | Shared Kernel (definido en 5.1, se referencia, no se redefine) |
| **Propósito** | Los 10 tipos de sensor soportados por los nodos. BC-02 crea un umbral por defecto por cada tipo aplicable al registrarse un dispositivo. |

---

##### 5. ISensorReadingRepository

| Campo | Detalle |
|---|---|
| **Nombre** | ISensorReadingRepository |
| **Categoría** | Repository (interfaz, contrato del agregado) |
| **Propósito** | Persistencia y consulta de lecturas en la base de datos propia del microservicio. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| AddAsync | Task | public | Agrega una lectura nueva. |
| FindByEdgeAndRange | Task\<IEnumerable\<SensorReading\>\> | public | Por MAC de gateway, rango de fechas, filtro opcional por nodo, con paginación. |
| FindByDeviceAndRange | Task\<IEnumerable\<SensorReading\>\> | public | Por MAC de nodo, rango de fechas, con paginación. |
| CountByBatch | Task\<int\> | public | Persistidas de un lote, para reconciliación. |

---

##### 6. IAgronomicThresholdRepository

| Campo | Detalle |
|---|---|
| **Nombre** | IAgronomicThresholdRepository |
| **Categoría** | Repository (interfaz) |
| **Propósito** | Persistencia y consulta de umbrales agronómicos. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| AddAsync | Task | public | Agrega un umbral nuevo. |
| Update | void | public | Marca el umbral como modificado. |
| FindByDevice | Task\<IEnumerable\<AgronomicThreshold\>\> | public | Umbrales de un nodo. |
| FindByDeviceAndType | Task\<AgronomicThreshold?\> | public | Un umbral por nodo y tipo. Retorna `null` si no existe. |
| Remove | void | public | Elimina el umbral. |

---

##### 7. ISensorReadingCommandService

| Campo | Detalle |
|---|---|
| **Nombre** | ISensorReadingCommandService |
| **Categoría** | Domain Service (interfaz) |
| **Propósito** | Contrato del servicio que procesa persistencia de lecturas, reconciliación de lotes y ajuste de umbrales. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Handle(RecordSensorReadingCommand) | Task | public | Persiste idempotente por `readingId` y evalúa contra el umbral vigente. |
| Handle(ProcessSynchronizedBatchCommand) | Task | public | Reconcilia conteo del lote y publica `ReadingsBatchStored`. |
| Handle(UpdateAgronomicThresholdCommand) | Task | public | Actualiza o crea el umbral y publica `ThresholdUpdated`. |

---

##### 8. ISensorReadingQueryService

| Campo | Detalle |
|---|---|
| **Nombre** | ISensorReadingQueryService |
| **Categoría** | Domain Service (interfaz) |
| **Propósito** | Contrato del servicio de consultas de lecturas. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Handle(ReadingsByGatewayQuery) | Task\<IEnumerable\<SensorReading\>\> | public | Historial por gateway con filtros y paginación. |
| Handle(ReadingsByDeviceQuery) | Task\<IEnumerable\<SensorReading\>\> | public | Historial por nodo con rango y paginación. |

---

##### 9. IAgronomicThresholdQueryService

| Campo | Detalle |
|---|---|
| **Nombre** | IAgronomicThresholdQueryService |
| **Categoría** | Domain Service (interfaz) |
| **Propósito** | Contrato del servicio de consultas de umbrales. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Handle(ThresholdsByDeviceQuery) | Task\<IEnumerable\<AgronomicThreshold\>\> | public | Todos los umbrales de un nodo. |

---

##### 10. IThresholdEvaluationService + ThresholdEvaluationService

| Campo | Detalle |
|---|---|
| **Nombre** | IThresholdEvaluationService / ThresholdEvaluationService |
| **Categoría** | Domain Service (interfaz + implementación) |
| **Propósito** | Evaluar si una lectura supera el rango de su umbral. |
| **Método** | `IsExceeded` → delega en `AgronomicThreshold.IsExceededBy`. |

---

##### 11. Commands

Objetos inmutables que encapsulan intención de cambio. Todos viajan con `CorrelationId` para trazabilidad e idempotencia.

| Nombre | Parámetros | Descripción |
|---|---|---|
| RecordSensorReadingCommand | ReadingId, DeviceMac, EdgeMac, SensorType, Value, MeasuredAt, CorrelationId | Persistencia de una lectura con evaluación. |
| ProcessSynchronizedBatchCommand | BatchId, EdgeMac, ReadingsCount, CorrelationId | Reconciliación de un lote sincronizado. |
| UpdateAgronomicThresholdCommand | DeviceMac, SensorType, MinValue, MaxValue, Description, CorrelationId | Ajuste de umbral con versionado. |

---

##### 12. Queries

Objetos inmutables de solo lectura.

| Nombre | Parámetros | Descripción |
|---|---|---|
| ReadingsByGatewayQuery | EdgeMac, DeviceMac (opcional), From, To, Page, Size | Historial por gateway. |
| ReadingsByDeviceQuery | DeviceMac, From, To, Page, Size | Historial por nodo. |
| ThresholdsByDeviceQuery | DeviceMac | Umbrales de un nodo. |

---

##### 13. Eventos de integración

BC-02 consume tres eventos v1 de BC-01 y publica tres propios, todos sobre RabbitMQ con entrega al menos una vez; los consumidores son idempotentes y existe dead-letter queue.

Consumidos (BC-01):

| Nombre | Versión | Cuándo | Contenido mínimo |
|---|---|---|---|
| IotDeviceRegistered | v1 | Alta de nodo confirmada. | deviceId, mac, edgeMac, zoneId, correlationId |
| SensorReadingRecorded | v1 | Por lectura aceptada. | readingId, deviceMac, sensorType, measuredAt, value, correlationId |
| EdgeDataSynchronized | v1 | Lote aceptado. | edgeMac, batchId, readingsCount, correlationId |

Publicados (BC-02):

| Nombre | Versión | Cuándo | Contenido mínimo |
|---|---|---|---|
| ThresholdExceeded | v1 | Lectura fuera de rango. | deviceMac, sensorType, value, minValue, maxValue, measuredAt, correlationId |
| ThresholdUpdated | v1 | Umbral ajustado (para propagar al edge vía BC-01). | deviceMac, sensorType, version, correlationId |
| ReadingsBatchStored | v1 | Lote reconciliado. | batchId, edgeMac, storedCount, correlationId |

---

### 5.2.2. Interface Layer.

Punto de entrada HTTP del microservicio. Todo el tráfico pasa por el API Gateway con JWT según rol; todos los endpoints requieren autenticación. Los controllers delegan en Application y solo exponen lectura de datos y gestión de umbrales: no existe endpoint de ingesta de lecturas, que entra exclusivamente por eventos desde BC-01.

El gateway es la única puerta y ningún endpoint queda anónimo. Los controllers son deliberadamente delgados —validan forma, convierten y delegan— para que las reglas vivan en dominio y aplicación, no en HTTP. Los resources son los contratos versionables de la API.

##### 1. SensorReadingsController

| Campo | Detalle |
|---|---|
| **Nombre** | SensorReadingsController |
| **Categoría** | Controller |
| **Ruta base** | `api/v1/sensor-readings` (vía API Gateway) |
| **Propósito** | Historial de lecturas por gateway o por nodo. |

**Métodos**

| Nombre | Verbo HTTP | Ruta | Auth | Tipo de retorno | Descripción |
|---|---|---|---|---|---|
| GetByGateway | GET | `/` | JWT-User | 200 OK | Por `edgeMac`, con filtros `from`, `to`, `deviceMac` y paginado. |
| GetByDevice | GET | `/{deviceMac}` | JWT-User | 200 OK | Historial del nodo con rango y paginado. |

##### 2. AgronomicThresholdsController

| Campo | Detalle |
|---|---|
| **Nombre** | AgronomicThresholdsController |
| **Categoría** | Controller |
| **Ruta base** | `api/v1/agronomic-thresholds` (vía API Gateway) |
| **Propósito** | Consulta y ajuste de umbrales por nodo. |

**Métodos**

| Nombre | Verbo HTTP | Ruta | Auth | Tipo de retorno | Descripción |
|---|---|---|---|---|---|
| GetByDevice | GET | `/` | JWT-User | 200 OK | Umbrales del nodo (`deviceMac`). |
| UpdateThreshold | PATCH | `/` | JWT-Admin | 200 OK | Ajuste parcial; crea el umbral si no existe. |

##### 3. Resources

Records inmutables de petición y respuesta.

| Nombre | Campos | Descripción |
|---|---|---|
| SensorReadingViewResource | edgeMac, deviceMac, sensorType, value, measureUnit, measuredAt | Respuesta de lectura. |
| ReadingHistoryQueryResource | edgeMac, deviceMac, from, to, page, size | Filtros de historial. |
| UpdateThresholdResource | sensorType, minValue, maxValue, description | Solicitud de ajuste. |
| ThresholdViewResource | edgeMac, deviceMac, sensorType, minValue, maxValue, version | Respuesta de umbral. |

##### 4. Assemblers

Clases estáticas que transforman entre recursos y objetos de dominio.

| Nombre | Método | Descripción |
|---|---|---|
| ReadingsByGatewayQueryFromResourceAssembler | ToQueryFromResource(ReadingHistoryQueryResource) | Query de historial. |
| ReadingsByDeviceQueryFromResourceAssembler | ToQueryFromResource(deviceMac, from, to, page, size) | Query por nodo. |
| UpdateAgronomicThresholdCommandFromResourceAssembler | ToCommandFromResource(deviceMac, UpdateThresholdResource) | Ajuste de umbral. |
| SensorReadingViewResourceFromAggregateAssembler | ToResourceFromAggregate(SensorReading) | Respuesta de lectura. |
| ThresholdViewResourceFromAggregateAssembler | ToResourceFromAggregate(AgronomicThreshold) | Respuesta de umbral. |
| ThresholdsByDeviceQueryFromResourceAssembler | ToQueryFromResource(deviceMac) | Query de umbrales. |

### 5.2.3. Application Layer.

Orquesta los flujos de negocio: recibe commands, queries y eventos, recupera agregados, aplica reglas, persiste mediante Unit of Work y publica eventos con Outbox transaccional (misma transacción del cambio, con relay al broker).

La capa separa escritura y lectura: la persistencia es idempotente por `readingId` (reprocesar un evento jamás duplica), la reconciliación compara conteo esperado contra `CountByBatch`, y cada mutación confirmada deja su evento en el Outbox dentro de la misma transacción. Las queries solo leen datos ya calculados.

##### 1. SensorReadingCommandService

| Campo | Detalle |
|---|---|
| **Nombre** | SensorReadingCommandService |
| **Categoría** | Command Service |
| **Propósito** | Flujos de persistencia, reconciliación y ajuste de umbrales. |
| **Atributos** | `uow: IUnitOfWork`, `readingRepository`, `thresholdRepository`, `evaluation: IThresholdEvaluationService`, `outbox: IOutboxWriter`. |

**Métodos (Handle)**

| Nombre | Descripción |
|---|---|
| Handle(RecordSensorReadingCommand) | `readingId` ya persistido se responde como éxito sin duplicar; crea la lectura vía factory, evalúa contra el umbral vigente y publica `ThresholdExceeded` si sale de rango. |
| Handle(ProcessSynchronizedBatchCommand) | Compara `readingsCount` contra `CountByBatch`; publica `ReadingsBatchStored` con el conteo reconciliado. |
| Handle(UpdateAgronomicThresholdCommand) | Actualiza o crea el umbral (nueva `Version`) y publica `ThresholdUpdated`. |

##### 2. SensorReadingQueryService

| Campo | Detalle |
|---|---|
| **Nombre** | SensorReadingQueryService |
| **Categoría** | Query Service |
| **Propósito** | Historial de lecturas, sin mutación. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Handle(ReadingsByGatewayQuery) | Task\<IEnumerable\<SensorReading\>\> | public | Historial por gateway con filtros y paginación. |
| Handle(ReadingsByDeviceQuery) | Task\<IEnumerable\<SensorReading\>\> | public | Historial por nodo con rango y paginación. |

##### 3. AgronomicThresholdQueryService

| Campo | Detalle |
|---|---|
| **Nombre** | AgronomicThresholdQueryService |
| **Categoría** | Query Service |
| **Propósito** | Lectura de umbrales, sin mutación. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Handle(ThresholdsByDeviceQuery) | Task\<IEnumerable\<AgronomicThreshold\>\> | public | Umbrales del nodo. |

##### 4. Handlers de eventos (RabbitMQ)

| Nombre | Consume | Propósito |
|---|---|---|
| IotDeviceRegisteredHandler | `IotDeviceRegistered` (BC-01) | Crea un umbral por defecto por cada `SensorType` aplicable usando `DefaultThresholdFactory`. Idempotente por `correlationId`. |
| SensorReadingRecordedHandler | `SensorReadingRecorded` (BC-01) | Convierte el evento en `RecordSensorReadingCommand` y delega al command service. |
| EdgeDataSynchronizedHandler | `EdgeDataSynchronized` (BC-01) | Convierte el evento en `ProcessSynchronizedBatchCommand` y delega al command service. |

##### 5. Factories

| Nombre | Método | Descripción |
|---|---|---|
| SensorReadingFactory | ForType(sensorType, value, measuredAt) | Crea la lectura asignando el `MeasureUnit` correcto (Percent para Humidity, Unknown para los demás). |
| DefaultThresholdFactory | ForType(deviceMac, edgeMac, sensorType) | Umbral por defecto: Temperature 10–40, Humidity 20–80; resto sin definir (`IsSet` falso). |

### 5.2.4. Infrastructure Layer.

Materialización del microservicio con persistencia y mensajería propias: base de datos exclusiva con migraciones propias y cero tablas compartidas.

La base propia es lo que hace real el límite del bounded context: el servicio evoluciona, migra y escala sin coordinar esquemas con nadie, y ninguna consulta cruza a tablas ajenas. Las referencias a dispositivos son MAC lógicas sin claves foráneas fuera del BC, porque esos datos viven en otra base. La mensajería sale por Outbox con relay para que la publicación sobreviva caídas.

##### 1. SensorDataDbContext

| Campo | Detalle |
|---|---|
| **Nombre** | SensorDataDbContext |
| **Categoría** | DbContext propio del microservicio (PostgreSQL, `DATABASE_URL` exclusiva) |
| **Propósito** | Acceso a datos del BC-02. El propio contexto actúa como Unit of Work (`SaveChanges` transaccional junto al Outbox). |
| **Tablas** | `sensor_readings` (`reading_id` único), `agronomic_thresholds`, `outbox_messages`. snake_case, sin FK fuera del BC. |

##### 2. SensorReadingRepository + AgronomicThresholdRepository

Implementan las interfaces de dominio con Entity Framework Core sobre el contexto propio, con búsqueda por MAC, rangos de fecha y paginación. Sin dependencias de acceso a datos fuera del servicio.

##### 3. RabbitMqEventPublisher + OutboxRelay

| Campo | Detalle |
|---|---|
| **Nombre** | RabbitMqEventPublisher / OutboxRelay |
| **Categoría** | Messaging (publisher + relay) |
| **Propósito** | Publicar eventos versionados (exchange por tipo, dead-letter queue). El relay drena `outbox_messages` y confirma la publicación; los consumidores son idempotentes por `readingId`, `batchId` y `correlationId`. |

##### 4. Consumers

Los tres handlers de 5.2.3 operan como consumers RabbitMQ con reintento y dead-letter queue; cada uno delega en el command service correspondiente sin lógica de negocio propia.
