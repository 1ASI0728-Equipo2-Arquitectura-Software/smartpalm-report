### 4.1.5. Quality Attribute Scenario Refinements

Al finalizar el QAW, los escenarios iniciales fueron refinados para incorporar las decisiones AD-01 a AD-05, eliminar ambigüedades y establecer medidas comprobables. El orden responde a la votación de stakeholders y al riesgo arquitectónico: primero se protege la continuidad del monitoreo y la confianza en los datos; luego la oportunidad de respuesta, la seguridad, la capacidad de crecimiento y la evolución de la plataforma.

#### Scenario Refinement for Scenario 1

| Campo | Refinamiento |
|---|---|
| **Scenario(s)** | QAS-01: continuidad del monitoreo sin Internet. |
| **Business Goals** | Evitar puntos ciegos de monitoreo y detección tardía en plantaciones remotas de la Amazonia peruana. |
| **Relevant Quality Attributes** | Availability, resilience, reliability. |
| **Stimulus** | Se pierde por completo la conectividad entre el Edge API y los servicios cloud. |
| **Stimulus Source** | Proveedor de Internet, infraestructura rural o condición climática. |
| **Environment** | Operación normal en campo, dispositivos y nodo edge energizados. |
| **Artifact (if Known)** | Sensor Firmware, Edge API, Edge DB y sincronizador. |
| **Response** | Los dispositivos siguen capturando; Edge API autentica, normaliza y evalúa umbrales; SQLite conserva las lecturas pendientes; al volver la conexión, el sincronizador transmite lotes en orden y espera confirmación antes de marcarlos como enviados. |
| **Response Measure** | Autonomía mínima de 72 horas a la frecuencia de muestreo prevista; 100% de lecturas válidas persistidas mientras exista capacidad; evaluación local <= 2 s p95; sincronización automática iniciada <= 60 s después de recuperar conexión. |
| **Questions** | ¿Cuál es la frecuencia máxima real de muestreo por zona? ¿Qué margen de almacenamiento se reservará para logs? ¿Cómo se informará al usuario que la nube muestra datos desactualizados? |
| **Issues** | Una interrupción superior a 72 horas puede agotar el almacenamiento. Deben definirse alertas de capacidad y una política de retención que preserve los registros más recientes sin ocultar la pérdida. |

#### Scenario Refinement for Scenario 2

| Campo | Refinamiento |
|---|---|
| **Scenario(s)** | QAS-03: sincronización idempotente tras interrupciones. |
| **Business Goals** | Mantener datos confiables para que las decisiones agronómicas no se basen en lecturas o alertas duplicadas. |
| **Relevant Quality Attributes** | Reliability, data integrity, recoverability. |
| **Stimulus** | El edge reenvía total o parcialmente un lote cuya confirmación se perdió durante una falla de red. |
| **Stimulus Source** | Sincronizador del Edge API. |
| **Environment** | Conectividad inestable; broker y servicios con semántica de entrega al menos una vez. |
| **Artifact (if Known)** | Ingestion Service, Event Broker, consumidores y sus bases de datos. |
| **Response** | Ingestion Service reconoce `readingId`, persiste únicamente lecturas nuevas y responde por elemento; los consumidores registran el identificador del evento antes de producir efectos; los mensajes que exceden los reintentos pasan a DLQ. |
| **Response Measure** | 0 duplicados persistidos y 0 alertas duplicadas en una prueba de al menos 10,000 mensajes con 20% de reenvíos; 100% de mensajes no procesables localizables en DLQ con `correlationId`. |
| **Questions** | ¿Durante cuánto tiempo se conservarán las claves de idempotencia? ¿Cómo se reprocesará la DLQ sin repetir efectos? |
| **Issues** | La deduplicación consume almacenamiento. Un período de retención menor que el máximo período de reintento permitiría duplicados tardíos. |

#### Scenario Refinement for Scenario 3

| Campo | Refinamiento |
|---|---|
| **Scenario(s)** | QAS-02: generación oportuna de una alerta crítica. |
| **Business Goals** | Dar al Palm Grower y al Agronomist tiempo suficiente para intervenir antes de que una condición de riesgo cause daño productivo. |
| **Relevant Quality Attributes** | Performance, availability. |
| **Stimulus** | Una lectura válida excede un umbral agronómico crítico vigente. |
| **Stimulus Source** | Dispositivo IoT registrado. |
| **Environment** | Edge y nube disponibles, carga nominal y FCM operativo. |
| **Artifact (if Known)** | Edge API, Ingestion Service, Event Broker, Alert Service y FCM adapter. |
| **Response** | Edge API retorna el indicador local; al llegar a nube se publica `ThresholdExceeded`; Alert Service clasifica, suprime duplicados y solicita la notificación push. |
| **Response Measure** | Indicador local <= 2 s p95 desde la recepción en edge; solicitud aceptada por FCM <= 10 s p95 desde la recepción en nube; al menos 99% de eventos críticos procesados sin intervención manual. |
| **Questions** | ¿La latencia de entrega final del dispositivo móvil se medirá separada del SLA interno? ¿Qué umbrales requieren notificación inmediata y cuáles solo registro? |
| **Issues** | FCM no garantiza el instante de visualización en el teléfono. Smart Palm medirá hasta la aceptación por el proveedor y mantendrá la alerta consultable en la aplicación. |

#### Scenario Refinement for Scenario 4

| Campo | Refinamiento |
|---|---|
| **Scenario(s)** | QAS-04: aislamiento multi-tenant y autenticación de dispositivos. |
| **Business Goals** | Proteger la confianza del cliente y evitar manipulación o divulgación de información productiva. |
| **Relevant Quality Attributes** | Security, auditability. |
| **Stimulus** | Un usuario solicita datos de una plantación ajena o un dispositivo no registrado intenta enviar lecturas. |
| **Stimulus Source** | Usuario autenticado sin autorización, atacante o dispositivo desconocido. |
| **Environment** | Plataforma operativa bajo tráfico normal o prueba de penetración. |
| **Artifact (if Known)** | API Gateway, Identity Service, microservicio propietario y Edge API. |
| **Response** | El gateway valida el token; el servicio verifica rol, tenant y vínculo con el recurso; Edge API comprueba la identidad del dispositivo; la solicitud se rechaza sin revelar datos y se registra para auditoría. |
| **Response Measure** | 100% de casos automatizados de acceso cruzado y dispositivos desconocidos reciben `401` o `403`; 0 registros sensibles en la respuesta; evento de auditoría disponible <= 5 s después del rechazo. |
| **Questions** | ¿Cómo se rotarán las credenciales de dispositivos instalados en campo? ¿Qué retención tendrán los eventos de auditoría? |
| **Issues** | Validar solo en el gateway no protege llamadas internas comprometidas; por ello se mantiene autorización en profundidad en cada microservicio. |

#### Scenario Refinement for Scenario 5

| Campo | Refinamiento |
|---|---|
| **Scenario(s)** | QAS-06: pico de telemetría. |
| **Business Goals** | Incorporar nuevas plantaciones y dispositivos sin degradar los flujos de suscripción, recomendaciones o gestión técnica. |
| **Relevant Quality Attributes** | Scalability, performance, availability. |
| **Stimulus** | La flota genera un pico agregado de 1,000 lecturas por minuto. |
| **Stimulus Source** | Dispositivos y nodos edge sincronizando de forma concurrente. |
| **Environment** | Restablecimiento de conectividad después de una interrupción regional. |
| **Artifact (if Known)** | API Gateway, Ingestion Service, Event Broker y base de datos de ingesta. |
| **Response** | El gateway limita abuso sin bloquear dispositivos válidos; Ingestion Service escala horizontalmente; el broker amortigua el pico y los consumidores aplican backpressure. |
| **Response Measure** | Aceptación sostenida >= 1,000 lecturas/min; tasa de error < 1%; 0 pérdida confirmada; cola drenada <= 5 min después de finalizar el pico; los demás servicios mantienen sus objetivos de respuesta. |
| **Questions** | ¿Cuántos dispositivos y qué frecuencia de muestreo representa la primera fase comercial? ¿El plan de Render permite el escalado requerido o solo se demostrará localmente? |
| **Issues** | El tier gratuito puede entrar en reposo o limitar recursos. La prueba de arquitectura debe distinguir restricciones del ambiente académico del objetivo de producción. |

#### Scenario Refinement for Scenario 6

| Campo | Refinamiento |
|---|---|
| **Scenario(s)** | QAS-05: consulta del dashboard consolidado. |
| **Business Goals** | Permitir que el Agronomist identifique rápidamente las plantaciones y zonas que requieren atención. |
| **Relevant Quality Attributes** | Performance, usability, availability. |
| **Stimulus** | Un Agronomist solicita la vista general de hasta 50 plantaciones asignadas. |
| **Stimulus Source** | Web Application. |
| **Environment** | Carga nominal; servicios fuente disponibles o temporalmente degradados. |
| **Artifact (if Known)** | Dashboard Service y su base de proyecciones. |
| **Response** | Consulta una vista materializada local, ordena por criticidad e incluye el instante de última actualización sin hacer fan-out síncrono a todos los servicios. |
| **Response Measure** | Respuesta <= 3 s p95; 95% de proyecciones actualizadas <= 30 s después del evento fuente; si una proyección está retrasada, la interfaz muestra su timestamp. |
| **Questions** | ¿Qué campos requieren consistencia inmediata? ¿Qué antigüedad máxima es aceptable para cada tipo de dato? |
| **Issues** | La consistencia eventual puede confundir al usuario; se requiere visibilidad del estado de actualización y un mecanismo de reconstrucción de proyecciones. |

#### Scenario Refinement for Scenario 7

| Campo | Refinamiento |
|---|---|
| **Scenario(s)** | QAS-07: cambio y despliegue independiente de un bounded context. |
| **Business Goals** | Reducir el tiempo y riesgo de evolución de Smart Palm conforme se validen nuevas reglas agronómicas y comerciales. |
| **Relevant Quality Attributes** | Modifiability, deployability, testability. |
| **Stimulus** | El equipo modifica la clasificación o política de notificación de Alert Service sin cambiar el contrato existente. |
| **Stimulus Source** | Equipo de desarrollo. |
| **Environment** | Plataforma desplegada con consumidores activos. |
| **Artifact (if Known)** | Alert Service, pipeline de despliegue y contratos de eventos. |
| **Response** | Se ejecutan pruebas unitarias, de contrato y smoke tests; se despliega solo Alert Service; los demás servicios continúan utilizando la versión compatible del evento. |
| **Response Measure** | Cambio desplegado en <= 30 min desde un artefacto aprobado; 0 redespliegues de otros servicios; 100% de contract tests aprobados; rollback <= 10 min. |
| **Questions** | ¿Qué estrategia de despliegue permite el proveedor académico? ¿Cuántas versiones de contrato se soportarán simultáneamente? |
| **Issues** | Separar repositorios o pipelines demasiado pronto puede aumentar carga operativa. La independencia se evaluará por artefacto y despliegue, aunque el código pueda residir inicialmente en un monorepo. |

#### Scenario Refinement for Scenario 8

| Campo | Refinamiento |
|---|---|
| **Scenario(s)** | QAS-08: degradación de una dependencia externa. |
| **Business Goals** | Mantener disponibles las capacidades principales y evitar que un proveedor externo detenga toda la plataforma. |
| **Relevant Quality Attributes** | Interoperability, resilience, availability. |
| **Stimulus** | Open-Meteo, FCM, Stripe o la fuente de parámetros del INIA no responde o devuelve errores. |
| **Stimulus Source** | Sistema externo. |
| **Environment** | Operación normal con una dependencia degradada. |
| **Artifact (if Known)** | Adaptador o ACL del microservicio propietario. |
| **Response** | Aplica timeout <= 3 s, reintenta solo errores transitorios hasta 3 veces, abre el circuito y devuelve una respuesta degradada o conserva el trabajo pendiente según la operación. |
| **Response Measure** | El circuito abre después del umbral configurado; 0 fallas propagadas a servicios no dependientes; operaciones pendientes conservadas; recuperación automática comprobada al cerrar el circuito. |
| **Questions** | ¿Qué operaciones pueden quedar pendientes y cuáles deben fallar de forma explícita? ¿Qué datos externos pueden almacenarse en caché y por cuánto tiempo? |
| **Issues** | Stripe exige confirmación consistente y no debe simular éxito. FCM permite diferir el envío; Open-Meteo e INIA pueden usar última información válida con timestamp visible. |

#### Scenario Refinement for Scenario 9

| Campo | Refinamiento |
|---|---|
| **Scenario(s)** | QAS-09: experiencia bilingüe y accesible. |
| **Business Goals** | Hacer que Smart Palm sea utilizable por sus dos segmentos objetivo y comunicable a audiencias técnicas y no técnicas. |
| **Relevant Quality Attributes** | Usability, accessibility, inclusivity. |
| **Stimulus** | Un usuario cambia de idioma durante una tarea o navega mediante teclado/lector de pantalla. |
| **Stimulus Source** | Palm Grower, Agronomist o visitante. |
| **Environment** | Landing Page, Web Application o Mobile Application en una sesión activa. |
| **Artifact (if Known)** | Capa de presentación y catálogos i18n. |
| **Response** | La interfaz cambia entre `es_419` y `en_US` sin perder el estado de la tarea; foco, etiquetas, roles, errores y contraste siguen siendo interpretables. |
| **Response Measure** | 100% de textos del flujo crítico traducidos; 0 pérdida de datos al cambiar idioma; navegación completa por teclado en web; conformidad WCAG 2.1 AA en auditoría de los flujos priorizados. |
| **Questions** | ¿La aplicación móvil se validará con TalkBack y VoiceOver? ¿Quién aprueba la terminología agronómica en ambos idiomas? |
| **Issues** | La traducción literal puede alterar el Ubiquitous Language. El glosario del dominio debe gobernar los catálogos de interfaz. |

#### Validación prevista

Los escenarios se comprobarán mediante pruebas de desconexión y reconexión del edge, inyección de mensajes repetidos, pruebas de carga, pruebas de autorización multi-tenant, contract tests, simulación de fallas externas y auditorías de accesibilidad. Los resultados deberán documentarse en el capítulo de implementación y utilizarse para actualizar este backlog cuando una medida no sea viable o cuando la evidencia permita establecer un objetivo más exigente.
