#### 4.2.2 Candidate Context Discovery


La sesión de Candidate Context Discovery se realizó sobre el tablero de Design-Level EventStorming en Miro. El proceso consistió en recorrer la línea temporal de eventos de izquierda a derecha aplicando la técnica *look-for-pivotal-events*, identificando aquellos eventos que señalan un cambio de responsabilidad entre partes del dominio: lo que ocurre antes del evento pertenece a un contexto distinto de lo que ocurre después.

Complementariamente, se aplicó la técnica *start-with-value* para validar que los contextos identificados como Core Domain concentraban las capacidades de mayor valor para el negocio: el procesamiento del dato sensorial, la recomendación agronómica calibrada para palma aceitera amazónica y la gestión técnica de campo del Agronomist.

##### Eventos pivote identificados

**`DeviceRegistered`**
Marca el límite entre la gestión del ciclo de vida del dispositivo físico y el procesamiento de los datos que ese dispositivo produce. Todo lo relacionado con registrar y configurar el dispositivo pertenece a un contexto; todo lo relacionado con recibir y procesar sus lecturas pertenece a otro.

![Design-Level EventStorming pivote 1](../../assets/chapter4/42-strategic-level-domain-driven-design/42-2-candidate-context-discovery/pivote_bc1_bc2.jpg)

**`ThresholdExceeded`**
Marca el límite entre el procesamiento de datos sensoriales y la gestión de alertas. Es el evento de mayor impacto operativo porque desencadena la respuesta hacia los usuarios.


![Design-Level EventStorming Pivote 2](../../assets/chapter4/42-strategic-level-domain-driven-design/42-2-candidate-context-discovery/pivote_bc2_bc3.jpg)

**`AlertAcknowledged`**
Marca el límite entre la gestión de alertas y la generación de recomendaciones agronómicas. Una alerta reconocida puede o no derivar en una recomendación — esa decisión pertenece a un contexto distinto con su propia lógica.

![Design-Level EventStorming Pivote 3](../../assets/chapter4/42-strategic-level-domain-driven-design/42-2-candidate-context-discovery/pivote_bc3_bc4.jpg)

**`RecommendationPublished`**
Marca el límite entre la generación de recomendaciones y su consumo para visualización. Una vez publicada, la recomendación pasa a ser un dato de solo lectura para el frontend.

![Design-Level EventStorming Pivote 4](../../assets/chapter4/42-strategic-level-domain-driven-design/42-2-candidate-context-discovery/pivote_bc4_bc5.jpg)

**`FieldInspectionRegistered`**
Marca el límite entre la gestión de la supervisión técnica del Agronomist y la generación de recomendaciones derivadas de esa inspección. La inspección pertenece al dominio del trabajo de campo; la recomendación que genera pertenece al dominio agronómico.

![Design-Level EventStorming Pivote 5](../../assets/chapter4/42-strategic-level-domain-driven-design/42-2-candidate-context-discovery/pivote_bc6_bc4.jpg)

**`SubscriptionActivated`**
Marca el límite entre la gestión comercial del usuario y el inicio de la operación del sistema. La activación de la suscripción habilita directamente el registro del dispositivo IoT en BC-01, a partir del cual el resto del sistema entra en operación de forma natural.

![Design-Level EventStorming Pivote 6](../../assets/chapter4/42-strategic-level-domain-driven-design/42-2-candidate-context-discovery/pivote_bc7_all.jpg)

##### Bounded contexts resultantes

| ID    | Bounded Context                  | Clasificación      | Responsabilidad central |
|-------|----------------------------------|--------------------|-------------------------|
| BC-01 | IoT Device Management            | Core Domain        | Ciclo de vida del dispositivo IoT en campo y operación offline mediante edge computing. |
| BC-02 | Sensor Data Processing           | Core Domain        | Recepción, validación, normalización y evaluación agronómica de lecturas sensoriales. |
| BC-03 | Alert & Notification             | Supporting Domain  | Generación, clasificación y despacho de alertas por umbral agronómico superado. |
| BC-04 | Agronomic Recommendation         | Core Domain        | Generación, aprobación y publicación de recomendaciones agronómicas por IA y por el Agronomist. |
| BC-05 | Crop Monitoring Dashboard        | Supporting Domain  | Vistas de lectura consolidadas del estado del cultivo para Palm Grower y Agronomist en la plataforma web. |
| BC-06 | Field Technical Management       | Core Domain        | Ciclo de supervisión técnica del Agronomist: visitas, inspecciones e intervenciones agronómicas. |
| BC-07 | Subscription & User Management   | Generic Subdomain  | Autenticación, autorización, perfiles y gestión de planes de suscripción. |

![Design-Level EventStorming Bounded 1](../../assets/chapter4/42-strategic-level-domain-driven-design/42-2-candidate-context-discovery/bc_01.jpg)
![Design-Level EventStorming Bounded 2](../../assets/chapter4/42-strategic-level-domain-driven-design/42-2-candidate-context-discovery/bc_02.jpg)
![Design-Level EventStorming Bounded 3](../../assets/chapter4/42-strategic-level-domain-driven-design/42-2-candidate-context-discovery/bc_03.jpg)
![Design-Level EventStorming Bounded 4](../../assets/chapter4/42-strategic-level-domain-driven-design/42-2-candidate-context-discovery/bc_04.jpg)
![Design-Level EventStorming Bounded 5](../../assets/chapter4/42-strategic-level-domain-driven-design/42-2-candidate-context-discovery/bc_05.jpg)
![Design-Level EventStorming Bounded 6](../../assets/chapter4/42-strategic-level-domain-driven-design/42-2-candidate-context-discovery/bc_06.jpg)
![Design-Level EventStorming Bounded 7](../../assets/chapter4/42-strategic-level-domain-driven-design/42-2-candidate-context-discovery/bc_07.jpg)