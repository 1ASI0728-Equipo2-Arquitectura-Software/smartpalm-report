### 4.1.3. Architectural Drivers Backlog

El Architectural Drivers Backlog se obtuvo mediante una sesión de Quality Attribute Workshop (QAW) adaptada al alcance académico. Primero se revisaron los objetivos de negocio y los pain points de Palm Grower y Agronomist; después se consolidaron las historias con impacto arquitectónico, se formularon escenarios de calidad medibles y se incorporaron todas las restricciones. Finalmente, los participantes priorizaron cada driver por importancia para los stakeholders y por complejidad técnica.

Los drivers se ordenan colocando primero la combinación **High/High**. Esta versión es un backlog vivo: sus medidas podrán ajustarse con evidencia de pruebas, pero cualquier cambio debe conservar la trazabilidad con las historias y decisiones de diseño.

| Driver ID | Título de Driver | Descripción | Importancia para Stakeholders | Impacto en Architecture Technical Complexity |
|---|---|---|---|---|
| CON-01 | Microservicios por bounded context | Implementar siete servicios desplegables de forma independiente, uno por bounded context, en lugar del monolito modular original. | High | High |
| CON-02 | Database per Service | Mantener propiedad exclusiva de datos por servicio y prohibir el acceso directo entre bases de datos. | High | High |
| CON-03 | Operación edge offline por 72 horas | Procesar y persistir lecturas localmente durante interrupciones prolongadas y sincronizarlas al recuperar conexión. | High | High |
| CON-04 | Eventos en la ruta crítica | Usar RabbitMQ para desacoplar ingesta, detección de umbrales, alertas, recomendaciones y proyecciones. | High | High |
| QAS-01 | Continuidad sin Internet | Conservar captura, evaluación local e integridad de lecturas mientras la nube no esté disponible. | High | High |
| QAS-02 | Alerta crítica oportuna | Evaluar localmente en <= 2 s y solicitar la notificación push en <= 10 s p95 desde la recepción en nube. | High | High |
| QAS-03 | Sincronización idempotente | Reintentar lotes sin duplicar lecturas, eventos ni alertas. | High | High |
| QAS-04 | Seguridad multi-tenant | Rechazar todo acceso cruzado entre suscripciones y toda telemetría de dispositivos no registrados. | High | High |
| QAS-06 | Escalabilidad de ingesta | Procesar al menos 1,000 lecturas por minuto y absorber picos mediante colas y escalado focalizado. | High | High |
| FD-03 | Sincronizar lecturas con la nube | Transferir registros pendientes al backend, confirmar recepción y preservar los no confirmados ante una interrupción. | High | High |
| FD-04 | Evaluar umbrales en el edge | Comparar cada lectura con los umbrales vigentes y producir indicadores aun sin acceso a la nube. | High | High |
| CON-05 | Integración multicomponente | Integrar aplicaciones web y móvil, Landing Page, firmware IoT, Edge API y APIs internas. | High | High |
| CON-06 | Acceso por API Gateway | Exponer los microservicios solamente mediante YARP con JWT y rate limiting. | High | Medium |
| CON-07 | Integraciones externas con propietario único | Encapsular Stripe, FCM, INIA y Open-Meteo en el servicio responsable mediante adaptadores o ACL. | High | Medium |
| FD-01 | Consultar dashboard consolidado | Proveer al Agronomist una vista priorizada de plantaciones, estados y alertas sin depender de fan-out síncrono. | High | Medium |
| FD-02 | Notificar alertas críticas | Convertir eventos de umbral en alertas clasificadas y notificaciones push sin bloquear la ingesta. | High | Medium |
| FD-05 | Personalizar umbrales | Permitir que un Agronomist autorizado cambie umbrales por plantación o zona y propagarlos al edge. | High | Medium |
| FD-06 | Registrar y publicar recomendaciones | Mantener la trazabilidad de recomendaciones y hacerlas visibles al Palm Grower. | High | Medium |
| FD-07 | Autenticar usuarios y dispositivos | Crear sesiones por rol y validar la identidad de cada dispositivo antes de aceptar telemetría. | High | Medium |
| QAS-05 | Dashboard responsivo | Responder la vista consolidada en <= 3 s p95 para hasta 50 plantaciones asignadas. | Medium | Medium |
| QAS-07 | Despliegue independiente | Modificar y desplegar un servicio en <= 30 min sin redesplegar los demás ni romper contratos compatibles. | Medium | High |
| QAS-08 | Fallos externos aislados | Evitar que fallas de Stripe, FCM, INIA u Open-Meteo se propaguen a capacidades no dependientes. | Medium | Medium |
| CON-08 | Stack abierto y presupuesto académico | Empaquetar con Docker y desplegar inicialmente en servicios cloud compatibles con tiers académicos o gratuitos. | Medium | Medium |
| CON-09 | Seguridad por rol y suscripción | Validar identidad, rol, suscripción y vínculo con la plantación en todas las operaciones protegidas. | High | Medium |
| QAS-09 | Experiencia bilingüe y accesible | Mantener contexto al cambiar idioma y cumplir WCAG 2.1 AA en los flujos críticos evaluados. | Medium | Medium |
| CON-10 | Internacionalización y accesibilidad | Soportar `es_419`, `en_US`, navegación por teclado, semántica y ARIA en las interfaces. | Medium | Low |

### Correspondencia con los inputs

| Driver | Input de origen |
|---|---|
| FD-01 | US007 |
| FD-02 | US026 |
| FD-03 | TS012 y TS013 |
| FD-04 | TS010 y TS022 |
| FD-05 | US021 y TS026 |
| FD-06 | US016 |
| FD-07 | US044 y TS015 |
| QAS-01 a QAS-09 | QA-01 a QA-09 |
| CON-01 a CON-10 | CTS001 a CTS010 |

Esta correspondencia permite revisar el impacto de un cambio: si una historia, medida o constraint se modifica, el equipo puede localizar los drivers y decisiones que requieren una nueva iteración de ADD.
