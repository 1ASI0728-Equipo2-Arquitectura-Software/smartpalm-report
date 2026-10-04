## 5.1. Bounded Context: IoT Device Management.

El bounded context **IoT Device Management** gestiona el ciclo de vida de los dispositivos IoT de SmartPalm y constituye el punto de entrada de toda la telemetría de campo a la plataforma: sin un dispositivo registrado y con suscripción activa no hay lecturas, y sin lecturas no operan el procesamiento (BC-02), las alertas (BC-03) ni el monitoreo (BC-05). Por eso es un Core Domain y se despliega como **microservicio independiente** con base de datos propia, capaz de evolucionar y escalar al ritmo de la ingesta sin arrastrar al resto de la solución.

Esta sección detalla su diseño táctico en el orden en que se construye y se lee: primero el modelo de dominio con sus reglas (5.1.1), luego la superficie HTTP que lo expone (5.1.2), la orquestación de los flujos (5.1.3), la materialización en persistencia y mensajería (5.1.4), y finalmente las vistas de arquitectura que lo verifican visualmente (5.1.6 y 5.1.7). Las capacidades cubiertas son seis: registrar dispositivos, configurar parámetros de muestreo, monitorear conectividad y salud, operar en modo offline, sincronizar datos acumulados y dar de baja dispositivos.

### 5.1.1. Domain Layer.

La Domain Layer concentra el núcleo del dominio: el agregado `EdgeDevice`, la entidad `IotDevice`, value objects, enumeraciones, interfaces de repositorio y de servicios de dominio, además de los commands, queries y eventos de integración que estructuran las operaciones del bounded context.

El agregado se delimita por gateway y microzona para que el registro, la sincronización y la baja sean una sola unidad de consistencia: ningún nodo existe fuera de su gateway y ninguna operación atraviesa agregados. La identidad combina un Guid generable sin conexión con la MAC como identidad de campo, y la configuración viaja como value object inmutable para que ningún cambio parcial deje al gateway en estado intermedio. El diccionario se lee ficha por ficha —categoría, propósito, atributos y métodos— y todo lo que aparece en los diagramas de 5.1.6 y 5.1.7 sale de aquí, sin elementos de más.

##### 1. EdgeDevice

| Campo | Detalle |
|---|---|
| **Nombre** | EdgeDevice |
| **Categoría** | Entity / Aggregate Root |
| **Propósito** | Gateway edge de una microzona: ciclo de vida, conectividad, configuración de muestreo y sincronización. Toda `IotDevice` se gobierna a través de este agregado. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| Id | Guid | private | Identificador único, generable offline sin coordinación. |
| MacAddress | string | private | Identidad de campo del gateway. Única, obligatoria. |
| MonitoringZoneId | Guid | private | Microzona activa asociada. Regla: exactamente una. |
| SamplingConfiguration | DeviceConfiguration | private | Value object con parámetros de muestreo vigentes. |
| LastConnectivityCheckAt | DateTime | private | Último heartbeat recibido. |
| LastSyncAt | DateTime | private | Última sincronización completada. |
| CreatedAt | DateTime | private | Fecha de registro. |
| IsConnected | bool | public | Calculada: tiempo desde `LastConnectivityCheckAt` dentro del umbral. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Register | void | public | Estado inicial al primer registro, con suscripción verificada. |
| UpdateSamplingConfiguration | void | public | Reemplaza el value object previa validación de rangos. |
| ReportConnectivity | void | public | Actualiza `LastConnectivityCheckAt`. |
| EnterOfflineMode | void | public | Activa modo offline al expirar el umbral de conectividad. |
| RestoreConnectivity | void | public | Sale de offline al recibir heartbeat o sincronización. |
| SynchronizeData | void | public | Actualiza `LastSyncAt` tras aceptar un lote idempotente. |
| Decommission | void | public | Baja del gateway y sus nodos; su telemetría se rechaza. |

---

##### 2. IotDevice

| Campo | Detalle |
|---|---|
| **Nombre** | IotDevice |
| **Categoría** | Entity (hija del agregado `EdgeDevice`) |
| **Propósito** | Nodo sensor individual bajo un edge gateway. Sin identidad global fuera del agregado. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| Id | Guid | private | Identificador único. |
| MacAddress | string | private | Identidad de campo. Única dentro del agregado. |
| Status | ActivationStatus | private | Active / Inactive / Decommissioned. |
| HealthStatus | DeviceHealthStatus | private | Healthy / Warning / Critical. |
| CreatedAt | DateTime | private | Fecha de registro. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Register | void | public | Alta bajo el agregado. |
| Decommission | void | public | Baja lógica; su telemetría se rechaza. |

---

##### 3. DeviceConfiguration

| Campo | Detalle |
|---|---|
| **Nombre** | DeviceConfiguration |
| **Categoría** | Value Object (inmutable, parte del agregado `EdgeDevice`) |
| **Propósito** | Parámetros de muestreo y transmisión de la microzona. Persistido como tipo propio en la fila del gateway. |

**Atributos**

| Nombre | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| SamplingIntervalMinutes | int | private | Período de muestreo. Rango válido: 1–1440. |
| TransmissionMode | string | private | `Realtime` \| `Batched`. |
| RetryPolicy | string | private | Política de reintento de envío. |
| MaxOfflineStorageHours | int | private | Tope de buffer offline. Fijo en 72, no parametrizable. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Validate | bool | public | Verifica rangos antes de reemplazar el value object. |

---

##### 4. SensorType

| Campo | Detalle |
|---|---|
| **Nombre** | SensorType |
| **Categoría** | Enumeration |
| **Propósito** | Tipos de sensor soportados por los nodos. |

**Valores**

| Nombre | Descripción |
|---|---|
| Temperature | Temperatura ambiental o del suelo. |
| Humidity | Humedad relativa ambiental o del suelo. |
| Pressure | Presión atmosférica. |
| Luminosity | Luminosidad. |
| GasResistance | Resistencia de gas. |
| Voltage | Voltaje eléctrico. |
| Current | Corriente eléctrica. |
| Power | Potencia eléctrica. |
| Speed | Velocidad. |
| Direction | Dirección u orientación. |

---

##### 5. ConnectivityStatus

| Campo | Detalle |
|---|---|
| **Nombre** | ConnectivityStatus |
| **Categoría** | Enumeration |
| **Propósito** | Estado de conectividad del gateway. |

**Valores**

| Nombre | Descripción |
|---|---|
| Connected | Heartbeat dentro del umbral. |
| Disconnected | Umbral expirado, sin datos recientes. |
| OfflineMode | Operando con buffer local. |

---

##### 6. DeviceHealthStatus

| Campo | Detalle |
|---|---|
| **Nombre** | DeviceHealthStatus |
| **Categoría** | Enumeration |
| **Propósito** | Salud del dispositivo. |

**Valores**

| Nombre | Descripción |
|---|---|
| Healthy | Operación normal. |
| Warning | Degradación (batería baja, pérdidas parciales). |
| Critical | Fuera de servicio / requiere intervención. |

---

##### 7. ActivationStatus

| Campo | Detalle |
|---|---|
| **Nombre** | ActivationStatus |
| **Categoría** | Enumeration |
| **Propósito** | Estado administrativo del dispositivo. |

**Valores**

| Nombre | Descripción |
|---|---|
| Active | En operación. |
| Inactive | Pausado temporalmente. |
| Decommissioned | Dado de baja; telemetría rechazada. |

---

##### 8. IEdgeDeviceRepository

| Campo | Detalle |
|---|---|
| **Nombre** | IEdgeDeviceRepository |
| **Categoría** | Repository (interfaz, contrato del agregado) |
| **Propósito** | Persistencia del agregado `EdgeDevice` en la base de datos propia del microservicio. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| AddAsync | Task | public | Agrega un agregado nuevo. |
| FindByIdAsync | Task\<EdgeDevice?\> | public | Busca por `Id`. Retorna `null` si no existe. |
| FindByMacAddressAsync | Task\<EdgeDevice?\> | public | Busca por `MacAddress`. Retorna `null` si no existe. |
| Update | void | public | Marca el agregado como modificado. |
| Remove | void | public | Elimina el agregado. |
| ListAsync | Task\<IEnumerable\<EdgeDevice\>\> | public | Todos los gateways registrados. |

---

##### 9. IIotDeviceRepository

| Campo | Detalle |
|---|---|
| **Nombre** | IIotDeviceRepository |
| **Categoría** | Repository (interfaz) |
| **Propósito** | Acceso a `IotDevice` siempre a través del agregado. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| FindByMacAddressAsync | Task\<IotDevice?\> | public | Busca por `MacAddress`. Retorna `null` si no existe. |
| ListByEdgeDeviceAsync | Task\<IEnumerable\<IotDevice\>\> | public | Nodos de un gateway. |

---

##### 10. IDeviceStatusCommandService

| Campo | Detalle |
|---|---|
| **Nombre** | IDeviceStatusCommandService |
| **Categoría** | Domain Service (interfaz) |
| **Propósito** | Contrato del servicio que procesa comandos de registro, configuración, baja y sincronización. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Handle(RegisterEdgeDeviceCommand) | Task | public | Comando de alta de gateway. |
| Handle(RegisterIotDeviceCommand) | Task | public | Comando de alta de nodo bajo un gateway. |
| Handle(UpdateSamplingConfigurationCommand) | Task | public | Comando de configuración de muestreo. |
| Handle(DecommissionDeviceCommand) | Task | public | Comando de baja de nodo. |
| Handle(DecommissionEdgeDeviceCommand) | Task | public | Comando de baja de gateway en cascada. |
| Handle(EdgeSynchronizationCommand) | Task | public | Comando de sincronización de lote idempotente. |
| Handle(ReportConnectivityCommand) | Task | public | Comando de heartbeat. |

---

##### 11. IDeviceStatusQueryService

| Campo | Detalle |
|---|---|
| **Nombre** | IDeviceStatusQueryService |
| **Categoría** | Domain Service (interfaz) |
| **Propósito** | Contrato del servicio de consultas de estado, registro y configuración. |

**Métodos**

| Nombre | Tipo de retorno | Visibilidad | Descripción |
|---|---|---|---|
| Handle(ConnectivityStatusQuery) | Task\<EdgeDevice\> | public | Estado de conectividad por MAC. |
| Handle(GatewayDevicesQuery) | Task\<Tuple\<EdgeDevice, List\<IotDevice\>\>\> | public | Nodos del gateway. |
| Handle(ListEdgeGatewaysQuery) | Task\<IEnumerable\<EdgeDevice\>\> | public | Todos los gateways registrados. |
| Handle(SamplingConfigurationQuery) | Task\<DeviceConfiguration\> | public | Configuración vigente, la que el edge debe aplicar. |

---

##### 12. IEdgeSynchronizationService + EdgeSynchronizationService

| Campo | Detalle |
|---|---|
| **Nombre** | IEdgeSynchronizationService / EdgeSynchronizationService |
| **Categoría** | Domain Service (interfaz + implementación) |
| **Propósito** | Ordenar cronológicamente las lecturas acumuladas. |
| **Método** | `OrderChronologically` → lista ordenada por `MeasuredAt` ascendente. |

---

##### 13. Commands

Objetos inmutables que encapsulan intención de cambio. Todos viajan con `CorrelationId` para trazabilidad e idempotencia.

| Nombre | Parámetros | Descripción |
|---|---|---|
| RegisterEdgeDeviceCommand | EdgeDeviceMac, MonitoringZoneId, CorrelationId | Alta de gateway. |
| RegisterIotDeviceCommand | EdgeDeviceMac, IotDeviceMac, CorrelationId | Alta de nodo bajo un gateway. |
| UpdateSamplingConfigurationCommand | EdgeDeviceMac, SamplingConfiguration, CorrelationId | Configuración de muestreo. |
| DecommissionDeviceCommand | IotDeviceMac, CorrelationId | Baja de nodo. |
| DecommissionEdgeDeviceCommand | EdgeDeviceMac, CorrelationId | Baja de gateway y sus nodos. |
| EdgeSynchronizationCommand | EdgeDeviceMac, BatchId, Readings[], CorrelationId | Sincronización de lote idempotente. |
| ReportConnectivityCommand | EdgeDeviceMac, CheckedAt, CorrelationId | Heartbeat de conectividad. |

---

##### 14. Queries

Objetos inmutables de solo lectura.

| Nombre | Parámetros | Descripción |
|---|---|---|
| ConnectivityStatusQuery | mac | Estado de conectividad por MAC. |
| GatewayDevicesQuery | EdgeDeviceMac | Nodos del gateway. |
| ListEdgeGatewaysQuery | — | Todos los gateways registrados. |
| SamplingConfigurationQuery | EdgeDeviceMac | Configuración vigente. |

---

##### 15. Eventos de integración

Eventos versionados sobre RabbitMQ con entrega al menos una vez; los consumidores son idempotentes y existe dead-letter queue. Publicados por BC-01:

| Nombre | Versión | Cuándo | Contenido mínimo |
|---|---|---|---|
| EdgeDeviceRegistered | v1 | Alta de gateway confirmada. | edgeId, mac, zoneId, correlationId |
| IotDeviceRegistered | v1 | Alta de nodo confirmada. | deviceId, mac, edgeMac, zoneId, correlationId |
| EdgeDataSynchronized | v1 | Lote aceptado. | edgeMac, batchId, readingsCount, correlationId |
| SensorReadingRecorded | v1 | Por lectura aceptada, en lote o en tiempo real. | readingId, deviceMac, sensorType, measuredAt, value, correlationId |
| DeviceDecommissioned | v1 | Baja confirmada. | deviceMac/edgeMac, correlationId |

BC-01 consume `SubscriptionActivated` (BC-07), que habilita el registro de dispositivos de la suscripción.

---
