#### 4.2.3 Domain Message Flows Modeling.


El modelado de flujos de mensajes entre bounded contexts se realizó mediante la técnica de Domain Storytelling, con el objetivo de visualizar cómo los contextos colaboran para resolver los casos de uso más críticos del negocio de Smart Palm. Se modelaron tres flujos principales que cubren los escenarios de mayor valor para los dos segmentos de usuario.

##### Flujo 1 — Detección de condición de riesgo y generación de recomendación

El dispositivo IoT registra una lectura sensorial y la envía al backend mediante HTTP. BC-02 Sensor Data Processing la recibe, la valida y la normaliza. Al evaluar la lectura contra los umbrales agronómicos calibrados para palma aceitera amazónica, detecta que el valor supera el límite definido y publica el evento `ThresholdExceeded`. BC-03 Alert & Notification consume ese evento, genera una alerta, la clasifica por nivel de severidad y la despacha como notificación push al Palm Grower y como alerta visible en la plataforma web para el Agronomist. El evento `AlertTriggered` es consumido opcionalmente por BC-04 Agronomic Recommendation, que genera una recomendación automática mediante el motor de IA. El Agronomist revisa y aprueba la recomendación desde la plataforma web. Una vez aprobada, se publica al Palm Grower. El Palm Grower ejecuta la intervención agronómica indicada y la registra en BC-06 Field Technical Management, cerrando el ciclo de trazabilidad.



##### Flujo 2 — Ciclo de supervisión del Agronomist con datos remotos

El Agronomist accede a la plataforma web y consulta BC-05 Crop Monitoring Dashboard para revisar el historial de parámetros sensoriales y las alertas activas de sus plantaciones antes de planificar una visita de campo. Con esa información, registra la planificación de la visita en BC-06 Field Technical Management. Durante la inspección presencial, registra sus observaciones directamente desde la plataforma web y las vincula a las alertas activas correspondientes. El evento `FieldInspectionRegistered` dispara la generación de una recomendación formal en BC-04 Agronomic Recommendation. El Agronomist la revisa, aprueba y publica. BC-05 Crop Monitoring Dashboard genera automáticamente un borrador de reporte técnico que el Agronomist revisa y publica hacia el Palm Grower.



##### Flujo 3 — Activación de suscripción e inicio de operación

Un Palm Grower se registra en la plataforma web y selecciona un plan de suscripción en BC-07 Subscription & User Management. El pago se procesa a través del Payment Gateway externo. Al confirmarse el pago, el sistema activa la suscripción y publica el evento `SubscriptionActivated`. BC-01 IoT Device Management consume ese evento y habilita el registro del dispositivo IoT asociado a la plantación del usuario. Una vez registrado y configurado el dispositivo, comienza la transmisión de lecturas hacia BC-02 Sensor Data Processing, poniendo en operación el Flujo 1.
