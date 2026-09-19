#### 4.1.1.3 Bounded Context Canvases.


A continuación se presentan los Bounded Context Canvases elaborados para cada uno de los siete bounded contexts identificados, se denotan todos los ambitos necesarios como Ubiquitous Language, IN-OUT Dependencies y demas puntos necesarios para construir el canvas.

##### BC-01: IoT Device Management

| Campo | Detalle |
|---|---|
| **Nombre** | IoT Device Management |
| **Descripción** | Gestiona el ciclo de vida completo de los dispositivos IoT de Smart Palm: registro, configuración de parámetros de muestreo, monitoreo del estado de conectividad, operación autónoma en modo offline mediante edge computing y sincronización de datos acumulados cuando se restablece la conexión. |
| **Rol estratégico** | Core Domain — diferenciador técnico central de la plataforma. |
| **Reglas de negocio** | Un dispositivo debe estar asociado a exactamente una Monitoring Zone activa. En modo offline el Edge Node almacena lecturas localmente. El período máximo de almacenamiento offline es de 72 horas. La sincronización se realiza en orden cronológico al restablecer conexión. El registro de un dispositivo requiere suscripción activa verificada en BC-07. |
| **Ubiquitous Language** | Device, Edge Node, Monitoring Zone, Sensor Reading, Offline Mode, Synchronization, Device Health Status. |
| **Capabilities** | Registrar dispositivo, configurar parámetros de muestreo, monitorear conectividad, activar modo offline, sincronizar datos acumulados, dar de baja dispositivo. |
| **Dependencias entrantes** | BC-07 Subscription & User Management — valida suscripción activa antes de permitir registro de dispositivo. |
| **Dependencias salientes** | BC-02 Sensor Data Processing — publica `SensorReadingRecorded` tras cada lectura o sincronización. |

---

##### BC-02: Sensor Data Processing

| Campo | Detalle |
|---|---|
| **Nombre** | Sensor Data Processing |
| **Descripción** | Recibe, valida, normaliza y persiste las lecturas sensoriales provenientes de los dispositivos IoT. Evalúa cada lectura contra los umbrales agronómicos calibrados para palma aceitera en la Amazonia peruana y determina si se debe publicar un evento de alerta. |
| **Rol estratégico** | Core Domain — procesamiento central del dato sensorial que alimenta toda la plataforma. |
| **Reglas de negocio** | Los umbrales agronómicos se definen por parámetro, por tipo de suelo y por fase fenológica del cultivo, calibrados con los parámetros del INIA para la región Ucayali. Una lectura fuera de rango genera el evento `ThresholdExceeded`. Lecturas duplicadas o con marca de tiempo inconsistente son descartadas. |
| **Ubiquitous Language** | Sensor Reading, Agronomic Threshold, ThresholdExceeded, Crop Health Status, Normalization, Validation. |
| **Capabilities** | Recibir lectura sensorial, validar integridad del dato, evaluar umbral agronómico, persistir serie temporal, publicar evento de umbral superado. |
| **Dependencias entrantes** | BC-01 IoT Device Management — `SensorReadingRecorded`. |
| **Dependencias salientes** | BC-03 Alert & Notification — `ThresholdExceeded`. BC-05 Crop Monitoring Dashboard — series temporales normalizadas para visualización. |

---

##### BC-03: Alert & Notification

| Campo | Detalle |
|---|---|
| **Nombre** | Alert & Notification |
| **Descripción** | Genera, clasifica y despacha alertas cuando una lectura sensorial supera un umbral agronómico. Gestiona los canales de notificación push hacia el Palm Grower y las alertas visibles en la plataforma web del Agronomist. |
| **Rol estratégico** | Supporting Domain — habilita la respuesta oportuna de los usuarios ante condiciones de riesgo. |
| **Reglas de negocio** | Las alertas se clasifican en tres niveles: informativa, de advertencia y crítica. Una alerta crítica activa notificación push inmediata. Se aplica supresión de alertas duplicadas para un mismo parámetro dentro de una ventana de 30 minutos. |
| **Ubiquitous Language** | Alert, Alert Level, Notification, Push Notification, Alert Suppression, Alert Acknowledgment. |
| **Capabilities** | Generar alerta, clasificar nivel de alerta, despachar notificación push, registrar acuse de recibo, suprimir duplicados. |
| **Dependencias entrantes** | BC-02 Sensor Data Processing — `ThresholdExceeded`. |
| **Dependencias salientes** | BC-04 Agronomic Recommendation — `AlertTriggered` como disparador opcional. BC-05 Crop Monitoring Dashboard — estado de alertas activas. |

---

##### BC-04: Agronomic Recommendation

| Campo | Detalle |
|---|---|
| **Nombre** | Agronomic Recommendation |
| **Descripción** | Gestiona la generación, almacenamiento y comunicación de recomendaciones agronómicas, tanto las producidas automáticamente por el motor de IA calibrado con parámetros del INIA como las redactadas manualmente por el Agronomist. |
| **Rol estratégico** | Core Domain — materializa el valor agronómico diferencial de la plataforma. |
| **Reglas de negocio** | Una recomendación debe estar vinculada a una alerta activa o a una inspección de campo registrada. Las recomendaciones generadas por IA requieren revisión y aprobación del Agronomist antes de ser publicadas al Palm Grower. Una recomendación publicada no puede modificarse; se versiona. |
| **Ubiquitous Language** | Agronomic Recommendation, AI Engine, Recommendation Approval, Recommendation Version, Agronomic Intervention. |
| **Capabilities** | Generar recomendación por IA, redactar recomendación manual, aprobar recomendación, publicar recomendación al Palm Grower, registrar intervención ejecutada. |
| **Dependencias entrantes** | BC-03 Alert & Notification — `AlertTriggered`. BC-06 Field Technical Management — `FieldInspectionRegistered`. |
| **Dependencias salientes** | BC-05 Crop Monitoring Dashboard — recomendaciones publicadas para visualización. |

---

##### BC-05: Crop Monitoring Dashboard

| Campo | Detalle |
|---|---|
| **Nombre** | Crop Monitoring Dashboard |
| **Descripción** | Provee las vistas de lectura consolidadas del estado del cultivo para ambos segmentos de usuario desde la plataforma web. Para el Palm Grower ofrece el Crop Health Status actual, el historial de parámetros y las alertas y recomendaciones activas. Para el Agronomist ofrece el dashboard multi-plantación, el historial de series temporales y la generación asistida de reportes técnicos. |
| **Rol estratégico** | Supporting Domain — interfaz principal de consumo de información de la plataforma. |
| **Reglas de negocio** | Este contexto es de solo lectura; no modifica estado del dominio. El Crop Health Status se calcula a partir del conjunto de parámetros sensoriales activos y se expresa en tres estados: óptimo, en riesgo o crítico. |
| **Ubiquitous Language** | Crop Health Status, Dashboard, Technical Report, Monitoring View, Time Series, Multi-plantation View. |
| **Capabilities** | Mostrar Crop Health Status actual, visualizar series temporales de parámetros, listar alertas activas, listar recomendaciones publicadas, generar borrador de reporte técnico, publicar reporte técnico. |
| **Dependencias entrantes** | BC-02 Sensor Data Processing, BC-03 Alert & Notification, BC-04 Agronomic Recommendation, BC-06 Field Technical Management. |
| **Dependencias salientes** | Ninguna — contexto de solo lectura. |

---

##### BC-06: Field Technical Management

| Campo | Detalle |
|---|---|
| **Nombre** | Field Technical Management |
| **Descripción** | Gestiona el ciclo de supervisión técnica del Agronomist: planificación de visitas de campo, registro de observaciones durante la inspección presencial, vinculación de observaciones a alertas activas y trazabilidad de las intervenciones agronómicas ejecutadas por el Palm Grower. |
| **Rol estratégico** | Core Domain — digitaliza el flujo de trabajo del Agronomist como segundo usuario primario de la plataforma. |
| **Reglas de negocio** | Una Field Inspection debe estar asociada a exactamente una Palm Plantation. El registro de una observación de campo puede vincular una alerta activa existente. Las intervenciones agronómicas registradas por el Palm Grower quedan trazadas contra la recomendación que las originó. |
| **Ubiquitous Language** | Field Inspection, Agronomist Visit, Observation, Agronomic Intervention, Traceability, Field Report. |
| **Capabilities** | Planificar visita de campo, registrar inspección, asociar observación a alerta activa, registrar intervención agronómica, consultar historial de intervenciones por plantación. |
| **Dependencias entrantes** | BC-03 Alert & Notification — alertas activas disponibles para vincular durante la inspección. |
| **Dependencias salientes** | BC-04 Agronomic Recommendation — `FieldInspectionRegistered` como disparador. BC-05 Crop Monitoring Dashboard — historial de inspecciones e intervenciones. |

---

##### BC-07: Subscription & User Management

| Campo | Detalle |
|---|---|
| **Nombre** | Subscription & User Management |
| **Descripción** | Gestiona la autenticación, autorización y perfiles de los usuarios de la plataforma, así como la contratación, activación, renovación y cancelación de los planes de suscripción SaaS de Smart Palm. |
| **Rol estratégico** | Generic Subdomain — infraestructura de soporte transversal a toda la plataforma. |
| **Reglas de negocio** | Un usuario solo puede tener una suscripción activa a la vez. El plan determina el número máximo de hectáreas monitoreables y el conjunto de funcionalidades disponibles. La cancelación de una suscripción revoca el acceso a la plataforma al término del período contratado. |
| **Ubiquitous Language** | Subscription Plan, User Profile, Role, Authentication, Authorization, Plan Activation, Billing Cycle. |
| **Capabilities** | Registrar usuario, autenticar usuario, gestionar roles y permisos, contratar plan, procesar pago, activar suscripción, renovar suscripción, cancelar suscripción. |
| **Dependencias entrantes** | Payment Gateway externo. |
| **Dependencias salientes** | BC-01 IoT Device Management — `SubscriptionActivated` habilita el registro de dispositivos. |