### 1.2.2. Lean UX Process

#### 1.2.2.1. Lean UX Problem Statements

**Problem Statement 1: Dueño del Cultivo**

Problem Statement: Gestión Agronómica de Palma Aceitera en la Amazonía Peruana
Nuestro contexto evidencia que la gestión de los cultivos de palma aceitera en la Amazonia peruana enfrenta severas restricciones tecnológicas y logísticas que afectan de manera conjunta a los dueños de los cultivos y a los ingenieros agrónomos. Actualmente, el monitoreo del estado agronómico depende de la observación visual manual, la cual es infrecuente y costosa en tiempo debido a las grandes distancias y el estado precario de las vías rurales. Esto deja a las plantaciones vulnerables ante condiciones climáticas exigentes —como altas precipitaciones de entre 1800 y 3500 mm anuales y el Fenómeno El Niño proyectado hasta 2027— que demandan una vigilancia fitosanitaria constante que las inspecciones físicas esporádicas no pueden garantizar. Hemos observado que la ausencia de datos continuos, objetivos y estructurados sobre las condiciones del cultivo obliga a ambos actores a operar bajo un modelo puramente reactivo. El productor amazónico carece de visibilidad continua del estado de sus plantas entre las visitas de campo, mientras que el ingeniero agrónomo se ve obligado a trabajar con información fragmentada y desactualizada. El factor crítico que genera insatisfacción es que esta desconexión de datos impide la toma de decisiones agronómicas preventivas y oportunas en una región donde el tiempo de respuesta es determinante. Como resultado, los dueños de cultivos sufren pérdidas productivas recurrentes por plagas y enfermedades que podrían mitigarse a una fracción del costo con detección temprana, y los ingenieros ven comprometida la calidad de sus recomendaciones y la capacidad de documentar intervenciones con respaldo de datos objetivos a través de reportes técnicos


---

#### 1.2.2.2. Lean UX Assumptions 

**Business Assumptions**

1. Creemos que existe una demanda real y sostenida por una solución de monitoreo IoT especializada en palma aceitera en la Amazonia peruana. La Resolución Ministerial N° 0046-2026-MIDAGRI que designa a la palma aceitera entre los cinco cultivos estratégicos priorizados para la agricultura familiar, junto con el Instrumento de Gestión 2025–2034 publicado en marzo de 2025, crean un entorno de política pública favorable a la adopción de herramientas que mejoren la productividad del pequeño y mediano palmicultor amazónico.

2. Creemos que el modelo de negocio SaaS con planes escalonados sin capa gratuita, diferenciados por hectáreas gestionadas y funcionalidades disponibles, es el esquema más sostenible para TempWise, generando ingresos recurrentes desde el primer cliente y permitiendo escalar desde el pequeño productor hasta la empresa agroindustrial con una misma arquitectura. Con más de 95 000 hectáreas en producción activa y más del 70% manejadas por pequeños y medianos productores en cooperativas (MIDAGRI, 2026), el mercado potencial direccionable es suficientemente amplio para sostener un modelo de crecimiento escalonado.

3. Creemos que los principales canales de adquisición de clientes serán las asociaciones de palmicultores como COCEPU y ASPASH en Ucayali, las cooperativas agrícolas regionales y las entidades como el INIA, el SENASA y el Gobierno Regional de Ucayali, que actúan como referentes técnicos de confianza para el productor amazónico. La alianza JUNPALMA-CENIPALMA-PNUD (2022) confirma que estos canales ya están activos y receptivos a soluciones tecnológicas validadas institucionalmente.

4. Creemos que la especialización en palma aceitera para condiciones amazónicas peruanas con parámetros calibrados para el régimen climático de alta pluviosidad, las enfermedades prioritarias de la región y los suelos ácidos característicos de la Amazonia, es una ventaja competitiva sostenible que ninguna solución genérica de agricultura de precisión puede replicar sin inversión local equivalente.

5. Creemos que TempWise puede alcanzar la autosuficiencia operativa dentro de los primeros dieciocho meses de operación comercial, sustentada en los ingresos por suscripción y el bajo costo marginal de incorporar nuevos clientes a la plataforma SaaS. La demanda interna de aceite de palma proyectada en más de 521 000 toneladas para 2025, un incremento del 157% respecto a 2015 (MIDAGRI, 2021), confirma que el sector tiene incentivos económicos sólidos para invertir en herramientas que eleven la productividad.

**Outcome Assumptions**

1. Creemos que el uso continuo de Smart Palm derivará en una reducción medible de las pérdidas productivas por detección tardía de enfermedades y plagas, traduciéndose en un retorno de inversión positivo y verificable dentro del primer ciclo productivo de uso.

2. Creemos que los palmicultores que adopten Smart Palm reportarán una mayor confianza en sus decisiones agronómicas, pasando de una gestión reactiva a una gestión preventiva y planificada del cultivo, de manera análoga a la transformación documentada en productores de Ucayali que, tras recibir asistencia técnica, comenzaron a aplicar fertilizantes y a controlar plagas de manera sistemática por primera vez (RSPO, 2022).

3. Creemos que los ingenieros agrónomos usuarios de la plataforma incrementarán su capacidad de gestión simultánea de plantaciones en zonas remotas, logrando supervisar entre un 30% y un 50% más de hectáreas sin incrementar su carga de trabajo ni deteriorar la calidad de sus intervenciones técnicas.

4. Creemos que TempWise generará valor de red a medida que crezca su base de usuarios, ya que los datos anonimizados acumulados por la plataforma mejorarán progresivamente la precisión de los modelos de IA calibrados para las condiciones amazónicas, beneficiando a todos los suscriptores activos.

**User Assumptions**

1. Creemos que el dueño del cultivo es el usuario primario de la aplicación móvil y que su principal motivación de adopción es la protección económica de su inversión. Asumimos que se trata de un productor adulto con acceso a smartphone de gama media-baja y conectividad 2G/3G intermitente, sin formación técnica agronómica formal, por lo que la plataforma debe traducir datos sensoriales en recomendaciones comprensibles y accionables sin requerir conocimiento técnico previo.

2. Creemos que el ingeniero agrónomo es el usuario primario de la interfaz web y que su adopción está motivada por la necesidad de eficiencia en la gestión remota de múltiples plantaciones. Asumimos que se trata de un profesional con titulación universitaria, familiarizado con herramientas digitales, que valora la precisión técnica de los datos, la trazabilidad de las intervenciones y la capacidad de generar documentación exportable para comunicar sus recomendaciones con respaldo objetivo.

3. Creemos que ambos segmentos perciben las visitas de campo frecuentes como costosas e ineficientes dentro del contexto geográfico amazónico, y que estarían dispuestos a adoptar una herramienta tecnológica que reduzca esa dependencia sin comprometer la calidad del diagnóstico agronómico.

4. Creemos que la adopción del dispositivo IoT por parte del productor amazónico requerirá un proceso de instalación guiada de baja fricción, dado que no puede asumirse que el usuario posea conocimientos de electrónica, configuración de hardware ni familiaridad con protocolos de comunicación inalámbrica como LoRaWAN.

5. Creemos que la conectividad intermitente es la condición operativa normal, no una excepción, en las zonas de cultivo de la Amazonia peruana, y que los usuarios esperan que el sistema funcione de manera autónoma y confiable durante períodos prolongados sin conexión activa a internet, sincronizando los datos acumulados en cuanto se restablezca el enlace.


**Feature Assumptions**

1. Creemos que las alertas automáticas en tiempo real ante parámetros fuera de rango son la funcionalidad de mayor valor percibido para el dueño del cultivo, al responder directamente a su necesidad de protección económica inmediata ante eventos fitosanitarios o climáticos.

2. Creemos que el módulo de generación de reportes técnicos exportables en PDF y Excel es la funcionalidad de mayor valor percibido para el ingeniero agrónomo, al permitirle documentar su trabajo, justificar sus recomendaciones ante el productor y cumplir exigencias de trazabilidad de organismos financiadores o certificadores.

3. Creemos que el canal de comunicación integrado entre el dueño del cultivo y el ingeniero agrónomo dentro de la misma plataforma es una funcionalidad diferenciadora, ya que conecta digitalmente a ambos actores en torno a los mismos datos del cultivo, reduciendo el riesgo de malentendidos en las instrucciones agronómicas.

4. Creemos que el motor de recomendaciones asistido por IA, calibrado con los parámetros agronómicos del INIA para las condiciones amazónicas peruanas, será percibido como una funcionalidad de alta credibilidad técnica por los ingenieros agrónomos, condición necesaria para su adopción como herramienta de soporte profesional.

5. Creemos que la visualización geoespacial complementada con índices de vegetación satelitales (NDVI) será valorada preferentemente por ingenieros que gestionan plantaciones superiores a 50 hectáreas, para quienes la perspectiva macro del estado espacial del cultivo aporta información no alcanzable con sensores puntuales en campo.

**User Outcome Assumptions**

1. Creemos que el dueño del cultivo que utilice Smart Palm durante al menos un ciclo productivo completo experimentará una reducción en la frecuencia de pérdidas económicas por detecciones tardías, aumentando su percepción de control sobre su inversión y su disposición a renovar la suscripción y recomendarla en su comunidad.

2. Creemos que el ingeniero agrónomo que adopte Smart Palm como herramienta de supervisión remota mejorará su reputación profesional ante sus clientes, derivada de la objetividad de los datos con los que fundamenta sus recomendaciones, lo que le permitirá gestionar un mayor número de plantaciones y elevar su tarifa de consultoría.

3. Creemos que la experiencia acumulada de uso reducirá progresivamente la curva de adopción tecnológica del productor, incrementando su disposición a explorar funcionalidades avanzadas y a migrar hacia planes de mayor cobertura conforme su plantación crezca.

4. Creemos que los usuarios que superen el período de prueba de treinta días y activen un plan de pago presentarán una tasa de abandono significativamente inferior al promedio del mercado SaaS agrícola, dado que el costo de abandonar la plataforma equivale a perder el historial acumulado de datos del cultivo y las alertas configuradas,lo cual actúa como un mecanismo natural de retención intrínseco al modelo.

---

#### 1.2.2.3. Lean UX Hypothesis Statements

**Hipótesis 1**

Creemos que se logrará una reducción significativa en el tiempo de detección de problemas agronómicos si el dueño del cultivo obtiene alertas preventivas sobre condiciones críticas con un dashboard móvil.
Sabremos que esto es cierto cuando veamos que al menos el 70% de los usuarios en entrevistas de validación reportan haber atendido una condición de riesgo antes de presentar síntomas visuales irreversibles.

**Hipótesis 2**

Creemos que se logrará gestionar un mayor número de cultivos con la misma carga de trabajo si el ingeniero agrónomo obtiene el monitoreo remoto de múltiples plantaciones con un panel web de datos sensoriales en tiempo real.
Sabremos que esto es cierto cuando veamos una reducción de al menos un 30% en la frecuencia de visitas físicas de rutina al campo por parte de los ingenieros, sin deterioro en sus recomendaciones.

**Hipótesis 3**

Creemos que se logrará una tasa de conversión a suscripción de pago superior al 40% si el usuario obtiene la oportunidad de validar el valor del sistema en su propio campo con un período de prueba de 30 días.
Sabremos que esto es cierto cuando veamos que al menos 4 de cada 10 usuarios en el CRM activan un plan de pago a los seis meses de iniciada la operación comercial.

**Hipótesis 4**

Creemos que se logrará la continuidad operativa del servicio sin interrupciones si el usuario obtiene autonomía de hardware en condiciones climáticas adversas con un dispositivo IoT de energía solar y protocolo LoRaWAN.
Sabremos que esto es cierto cuando veamos una tasa de entrega de paquetes de datos superior al 90% durante 30 días consecutivos de operación que incluyan lluvias intensas en Ucayali.

**Hipótesis 5**

Creemos que se logrará la adopción masiva de la plataforma como herramienta de soporte profesional si el ingeniero agrónomo obtiene recomendaciones técnicamente precisas con un motor de IA calibrado con parámetros del INIA.
Sabremos que esto es cierto cuando veamos que al menos el 75% de los ingenieros califica las recomendaciones como "útiles" o "muy útiles" en las entrevistas de validación.

---

#### 1.2.2.4. Lean UX Canvas

A continuación se presenta el Lean UX Canvas de Smart Palm, que sintetiza los elementos clave del proceso Lean UX desarrollado en las secciones anteriores.



| Elemento | Contenido |
|----------|-----------|
| **1. Business Problem** | Los palmicultores amazónicos peruanos gestionan sus cultivos de manera reactiva, sin acceso a datos continuos sobre el estado agronómico de sus plantaciones. Esto genera pérdidas productivas por detección tardía de plagas, enfermedades y deficiencias nutricionales. La brecha entre el rendimiento real del productor tradicional (≈10 t/ha) y el potencial demostrado (≥20 t/ha con tecnificación) equivale a hasta USD 1700/ha/año en ingresos no capturados (Gobierno Regional de Ucayali, 2016). |
| **2. Business Outcomes** | Captación de al menos 50 suscriptores activos en el primer año de operación. Tasa de retención mensual superior al 85%. Ingresos recurrentes mensuales que cubran los costos operativos de la plataforma al cabo del primer año. Posicionamiento de TempWise como referente de AgTech especializado en palma aceitera amazónica en el Perú. |
| **3. Users** | **Dueño del cultivo:** Palmicultor amazónico de pequeña y mediana escala (5–100 ha), residente en zonas rurales de Ucayali, San Martín o Loreto, con smartphone y conectividad 2G/3G intermitente, motivado por la protección económica de su inversión. **Ingeniero agrónomo:** Profesional con base en ciudades como Pucallpa, Tarapoto o Yurimaguas, que supervisa múltiples plantaciones en terrenos de difícil acceso. |
| **4. User Benefits** | Para el dueño: visibilidad continua del cultivo sin depender de conexión permanente, alertas proactivas ante condiciones críticas del entorno húmedo tropical, decisiones informadas sin requerir formación agronómica formal. Para el ingeniero: supervisión remota de plantaciones en zonas inaccesibles, datos calibrados para las condiciones de la Amazonia peruana, reportes técnicos automatizados y exportables. |
| **5. Solution Ideas** | Dispositivo IoT con sensores de humedad del suelo, temperatura, pH, conductividad eléctrica y módulo de cámara calibrado para operar en condiciones de alta humedad amazónica. Arquitectura edge computing con LoRaWAN para operación autónoma en zonas sin conectividad. Panel solar con batería de respaldo para autonomía energética en campo remoto. Aplicación móvil con dashboard simplificado y alertas push para el dueño del cultivo. Plataforma web con panel técnico avanzado para el ingeniero agrónomo. Motor de recomendaciones con IA calibrado con parámetros del INIA para la región Ucayali. Modelo SaaS con tres planes escalonados por hectáreas: Semilla (hasta 10 ha), Cosecha (10–50 ha) y Palma Pro (50+ ha). |
| **6. Hypotheses** | - Creemos que si proporcionamos al dueño del cultivo un dashboard móvil con alertas en tiempo real sobre condiciones críticas de su plantación de palma aceitera, entonces experimentará una reducción significativa en el tiempo de detección de problemas agronómicos. Sabremos que esto es verdad cuando, en las entrevistas de validación, al menos el 70% de los usuarios reporten haber detectado y atendido una condición de riesgo de manera oportuna gracias a las alertas del sistema, antes de que se manifestaran síntomas visuales irreversibles en el cultivo. <br> - Creemos que si ofrecemos al ingeniero agrónomo un panel web con acceso remoto a datos sensoriales históricos y en tiempo real de múltiples plantaciones, junto con herramientas de registro de intervenciones y generación de reportes exportables, entonces podrá gestionar un mayor número de cultivos con la misma carga de trabajo. Sabremos que esto es verdad cuando los ingenieros usuarios reporten haber reducido en al menos un 30% la frecuencia de visitas físicas de rutina a campo, sin deterioro en la calidad de sus recomendaciones agronómicas. <br> - Creemos que si implementamos un modelo de precios escalonado por hectáreas y funcionalidades sin capa gratuita, pero con un período de prueba de 30 días, entonces lograremos una tasa de conversión de prueba a suscripción de pago superior al 40%. Sabremos que esto es verdad cuando, al cabo de los primeros seis meses de operación comercial, los datos del CRM muestren que al menos 4 de cada 10 usuarios que completaron el período de prueba activaron un plan de pago activo. <br> - Creemos que si el dispositivo IoT de Smart Palm opera con autonomía energética solar y protocolo LoRaWAN en condiciones de campo amazónico, como los períodos de mayor pluviosidad, entonces los usuarios no experimentarán interrupciones operativas significativas. Sabremos que esto es verdad cuando, durante las pruebas de campo del prototipo en Ucayali, el dispositivo mantenga una tasa de entrega de paquetes de datos superior al 90% durante al menos 30 días consecutivos de operación autónoma, incluyendo al menos un episodio de precipitación intensa documentado. <br> - Creemos que si las recomendaciones generadas por el motor de IA de Smart Palm están calibradas con los parámetros del INIA para las condiciones amazónicas peruanas, entonces los ingenieros agrónomos las percibirán como técnicamente válidas y adoptarán la plataforma como herramienta de soporte profesional. Sabremos que esto es verdad cuando, en las entrevistas de validación, al menos el 75% de los ingenieros califique las recomendaciones generadas como "útiles" o "muy útiles" en el contexto real de sus plantaciones.|
| **7. What's the most important thing we need to learn first?** | - ¿El dueño del cultivo amazónico tomará acción oportuna y autónoma ante una alerta del sistema, o su respuesta seguirá condicionada por la necesidad de confirmación presencial de un técnico, haciendo que la alerta no genere valor real? <br> - ¿El ingeniero agrónomo confiará en los datos del sensor como base suficiente para tomar decisiones técnicas sin visitar el campo, o los percibirá como insuficientes para reemplazar la inspección presencial, reduciendo la plataforma a un complemento de bajo impacto? <br> - ¿El palmicultor amazónico de pequeña escala estará dispuesto a pagar una suscripción mensual por una herramienta de monitoreo digital antes de haber experimentado personalmente un retorno económico concreto derivado de su uso <br> - ¿Las condiciones ambientales extremas de la Amazonia, como humedad, calor y lluvia intensa, degradarán los sensores o interrumpirán la transmisión LoRaWAN hasta hacer el sistema percibido como no confiable por el usuario? <br> - ¿Los ingenieros agrónomos aceptarán recomendaciones generadas por un modelo de IA sin conocer su base de entrenamiento ni haber verificado su comportamiento en condiciones locales reales? <br>**El supuesto más riesgoso en esta etapa temprana es el siguiente.** Si el palmicultor amazónico no está dispuesto a comprometer un gasto recurrente antes de verificar un retorno concreto, el modelo de negocio SaaS sin capa gratuita colapsa en el mercado objetivo primario, independientemente de la calidad técnica de la solución. Es un riesgo de valor, no de viabilidad, y por ello es el más crítico de abordar primero. |
| **8. What's the least amount of work we need to do to learn the next most important thing?** | Realizar entrevistas con los segmentos objetivos, encuestas y un Producto Minimo Viable (MVP) para validar la hipótesis de que necesitan una solución avanzada para la gestión de cultivos de palma aceitera. Esto nos permitirá obtener resultados rápidamente con una mínima inversión de tiempo y recursos. |

---
