## 2.4. Ubiquitous Language

El Ubiquitous Language de Smart Palm establece un glosario de términos y conceptos del dominio de negocio utilizados de manera consistente por todos los miembros del equipo y los stakeholders del proyecto. Los términos se presentan en inglés como idioma principal, con el equivalente en español entre paréntesis cuando aplica. Se incluyen únicamente términos del dominio agrícola y de negocio; los términos técnicos de ingeniería de software quedan excluidos de este glosario.

| Término (inglés) | Equivalente (español) | Definición en el contexto de Smart Palm |
|------------------|-----------------------|------------------------------------------|
| **Palm Grower** | Dueño del cultivo / Palmicultor | Persona natural o familia propietaria de una o más plantaciones de palma aceitera en la Amazonia peruana. Usuario primario de la aplicación móvil de Smart Palm. |
| **Agronomist** | Ingeniero agrónomo | Profesional con titulación en agronomía que supervisa el estado técnico de las plantaciones y emite recomendaciones agronómicas. Usuario primario de la plataforma web de Smart Palm. |
| **Palm Plantation** | Plantación de palma aceitera | Unidad productiva compuesta por un conjunto de palmeras ubicadas en una parcela delimitada, gestionada por un Palm Grower. |
| **Palm Tree** | Palmera | Individuo vegetal de la especie *Elaeis guineensis* cultivado en la plantación. Unidad mínima de monitoreo dentro de una Palm Plantation. |
| **Fresh Fruit Bunch (FFB)** | Racimo de Fruta Fresca (RFF) | Racimo de frutos maduros cosechado de la palmera. Unidad de medida de la producción y base del cálculo del rendimiento por hectárea. |
| **Crude Palm Oil (CPO)** | Aceite Crudo de Palma (ACP) | Producto derivado del procesamiento de los FFB en planta extractora. Producto final comercializable de la cadena productiva. |
| **Crop Yield** | Rendimiento del cultivo | Cantidad de FFB producida por hectárea en un período dado, expresada en toneladas métricas por hectárea por año (t/ha/año). Indicador central de productividad en Smart Palm. |
| **Agronomic Threshold** | Umbral agronómico | Valor límite de un parámetro sensorial por encima o por debajo del cual el sistema genera una alerta. Definido con base en los parámetros del INIA para la región Ucayali. |
| **Sensor Reading** | Lectura sensorial | Valor numérico registrado por un sensor del dispositivo IoT en un momento determinado. Dato bruto antes de ser procesado por la plataforma. |
| **Alert** | Alerta | Notificación generada automáticamente cuando una Sensor Reading supera un Agronomic Threshold. Puede ser de tipo informativa, de advertencia o crítica. |
| **Agronomic Intervention** | Intervención agronómica | Acción técnica realizada sobre la plantación: aplicación de fertilizante, tratamiento fitosanitario, poda, cosecha. Debe registrarse en la plataforma para mantener la trazabilidad del cultivo. |
| **Agronomic Recommendation** | Recomendación agronómica | Instrucción técnica generada por el motor de IA de Smart Palm o redactada por el Agronomist, dirigida al Palm Grower con indicaciones concretas de acción sobre su cultivo. |
| **Field Inspection** | Inspección de campo | Visita presencial del Agronomist a la plantación para evaluar su estado mediante observación directa. Actividad que Smart Palm busca hacer más eficiente y menos frecuente. |
| **Crop Health Status** | Estado de salud del cultivo | Condición general de la plantación derivada de la combinación de los parámetros sensoriales actuales, expresada de manera comprensible para el Palm Grower: óptimo, en riesgo o crítico. |
| **Subscription Plan** | Plan de suscripción | Nivel de servicio contratado por el usuario en el modelo SaaS de Smart Palm, diferenciado por el área máxima gestionable (hectáreas) y el conjunto de funcionalidades disponibles. |
| **Monitoring Zone** | Zona de monitoreo | Subárea delimitada dentro de una Palm Plantation a la que se asigna uno o más dispositivos IoT para su supervisión diferenciada. |
| **Edge Node** | Nodo de borde | Componente del dispositivo IoT que procesa datos localmente en campo sin conexión activa a la nube, garantizando la operación del sistema en zonas sin conectividad. |
| **Bud Rot** | Pudrición del Cogollo (PC) | Enfermedad de etiología no completamente determinada que afecta el tejido apical de la palmera y puede causar su muerte si no se detecta en etapas tempranas. Considerada la enfermedad más limitante del cultivo en América Latina. |
| **Sudden Wilt** | Marchitez Sorpresiva | Enfermedad letal asociada a una fitoplasma transmitida por el chinche del género *Lyncus sp.*, de creciente incidencia en el corredor Aguaytía de Ucayali. |
| **Defoliator** | Insecto defoliador | Plaga que consume el tejido foliar de la palmera, reduciendo su área fotosintética activa. En Ucayali destacan *Alurnus humeralis* y *Opsiphanes cassina*, entre otros. |
| **Technical Report** | Reporte técnico | Documento estructurado generado por el Agronomist a partir de los datos del cultivo en Smart Palm, utilizado para comunicar el estado de la plantación al Palm Grower o a entidades externas como cooperativas, financiadoras u organismos de certificación. |