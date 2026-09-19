### 4.1.1. Design Purpose

El propósito del proceso de Attribute-Driven Design (ADD) de Smart Palm es transformar las necesidades de los palmicultores e ingenieros agrónomos de la Amazonia peruana en decisiones arquitectónicas verificables. La solución debe reducir la dependencia de inspecciones manuales esporádicas y permitir que una lectura capturada en campo se convierta, aun bajo conectividad intermitente, en información técnica, una alerta o una recomendación agronómica oportuna.

El problema no se limita a presentar datos en una aplicación. Smart Palm debe operar en plantaciones con cobertura de red irregular, conservar las lecturas durante interrupciones, procesar umbrales cerca de la fuente y sincronizar la información sin duplicarla cuando regrese la conexión. Al mismo tiempo, debe ofrecer al Palm Grower una experiencia móvil simple para conocer el estado de sus cultivos y al Agronomist una experiencia web que le permita supervisar varias plantaciones, priorizar zonas críticas, ajustar umbrales y documentar recomendaciones e intervenciones.

El diseño también debe sostener el modelo de negocio SaaS de TempWise. La plataforma tiene que incorporar nuevos clientes, plantaciones y dispositivos sin comprometer el aislamiento de datos entre suscriptores; integrar pagos, notificaciones y fuentes agronómicas o climáticas externas; y permitir que las capacidades de mayor demanda evolucionen y se desplieguen de manera independiente. Por ello, para esta nueva versión se adopta una arquitectura de microservicios alineada con los bounded contexts identificados en el diseño estratégico de dominio, en reemplazo del monolito modular utilizado como referencia en el proyecto original.

#### Objetivos del diseño

El proceso ADD persigue los siguientes objetivos:

1. **Continuidad operativa en campo:** mantener la captura, validación y evaluación básica de lecturas cuando no exista conexión con la nube, con almacenamiento local de hasta 72 horas y sincronización posterior.
2. **Respuesta agronómica oportuna:** detectar condiciones fuera de umbral y comunicar alertas críticas con una latencia controlada cuando exista conectividad.
3. **Integridad y trazabilidad:** evitar pérdida, duplicación o desorden de lecturas durante reintentos y conservar la relación entre lectura, alerta, recomendación e intervención.
4. **Seguridad y aislamiento:** autenticar personas y dispositivos, aplicar autorización por rol y suscripción, y evitar el acceso cruzado a plantaciones de otros clientes.
5. **Evolución independiente:** separar las capacidades del dominio en microservicios desplegables por bounded context, con propiedad explícita de sus datos e integraciones.
6. **Escalabilidad focalizada:** permitir que la ingesta y el procesamiento sensorial escalen sin obligar a replicar los servicios de suscripción, recomendaciones o gestión de campo.
7. **Experiencia inclusiva y consistente:** ofrecer interfaces en español latinoamericano e inglés, accesibles y coherentes entre el Landing Page, la Web Application y la Mobile Application.

#### Alcance del proceso ADD

El alcance comprende los productos digitales y componentes que participan en el ciclo de monitoreo: Landing Page, Web Application, Mobile Application, dispositivos IoT, Edge API, API Gateway, broker de eventos y siete microservicios asociados a los bounded contexts **IoT Device Management**, **Sensor Data Processing**, **Alert & Notification**, **Agronomic Recommendation**, **Crop Monitoring Dashboard**, **Field Technical Management** y **Subscription & User Management**. También considera sus bases de datos independientes y las integraciones con Stripe, Firebase Cloud Messaging, parámetros agronómicos del INIA, Open-Meteo y la red LoRaWAN.

No se busca definir en esta sección el diseño interno de clases de cada microservicio. Ese detalle corresponde al diseño táctico. El resultado esperado aquí es un conjunto trazable de drivers, decisiones y escenarios medibles que sirva de fundamento para los diagramas C4, el despliegue y la posterior validación de la arquitectura.
