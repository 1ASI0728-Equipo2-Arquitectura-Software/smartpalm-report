
### 4.2.5. Context Mapping.


El Context Mapping define las relaciones estructurales entre los siete bounded contexts de Smart Palm. El proceso consistió en revisar las dependencias identificadas en los Bounded Context Canvases y determinar el patrón de relación más adecuado para cada par de contextos relacionados, considerando el nivel de acoplamiento, la dirección del flujo de datos y el impacto sobre el modelo de dominio de cada contexto.

#### Relaciones identificadas

**BC-07 → BC-01: Customer/Supplier**
Subscription & User Management actúa como Supplier: provee la confirmación de suscripción activa que BC-01 IoT Device Management requiere antes de permitir el registro de un dispositivo. BC-01 es el Customer: consume ese dato sin poder modificar la lógica del contexto proveedor. La comunicación ocurre mediante el evento `SubscriptionActivated`.

**BC-01 → BC-02: Customer/Supplier**
BC-01 IoT Device Management produce las lecturas sensoriales y las publica como eventos HTTP hacia BC-02 Sensor Data Processing. BC-02 las consume y procesa sin control sobre el formato ni la frecuencia de las lecturas.

**BC-02 → BC-03: Customer/Supplier**
BC-02 Sensor Data Processing publica el evento `ThresholdExceeded`. BC-03 Alert & Notification lo consume para generar alertas. BC-03 no controla cuándo ni cómo se produce ese evento.

**BC-02 → BC-05: Customer/Supplier**
BC-02 provee las series temporales normalizadas que BC-05 Crop Monitoring Dashboard proyecta en sus vistas de lectura. BC-05 consume esos datos sin modificar el modelo del contexto productor.

**BC-03 → BC-04: Customer/Supplier**
BC-03 Alert & Notification publica `AlertTriggered` como disparador opcional para la generación automática de recomendaciones en BC-04 Agronomic Recommendation. BC-04 mantiene su propia lógica de generación y aprobación con independencia del contexto de alertas.

**BC-03 → BC-05: Customer/Supplier**
BC-03 provee el estado de alertas activas que BC-05 Crop Monitoring Dashboard proyecta en sus vistas. BC-05 es consumidor de solo lectura.

**BC-06 → BC-04: Customer/Supplier**
BC-06 Field Technical Management publica `FieldInspectionRegistered` como disparador de recomendaciones agronómicas asociadas a inspecciones presenciales. BC-04 consume ese evento.

**BC-06 → BC-05: Customer/Supplier**
BC-06 provee el historial de inspecciones e intervenciones agronómicas que BC-05 Crop Monitoring Dashboard proyecta en sus vistas de trazabilidad.

**BC-04 → BC-05: Customer/Supplier**
BC-04 Agronomic Recommendation publica las recomendaciones aprobadas que BC-05 presenta al Palm Grower y al Agronomist en la plataforma web.

**BC-07 → todos los contextos: Conformist**
Todos los contextos consumen la identidad y los permisos del usuario provistos por BC-07 Subscription & User Management para validar el acceso a sus operaciones. Ningún contexto puede modificar el modelo de identidad — deben conformarse con lo que este contexto define.