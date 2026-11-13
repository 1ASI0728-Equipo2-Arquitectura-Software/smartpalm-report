### 7.3.3. Evaluaciones según heurísticas

**Esta evaluación fue realizada por el Equipo 2 (TempWise):**

## Evaluación Heurística de Usabilidad y Diseño Inclusivo para la Aplicación: "SmartPalm"

**UX Heuristics & Principles Evaluation**

**Usability – Inclusive Design – Information Architecture**

**CARRERA:** Ingeniería de Software

**CURSO:** Arquitectura de Software

**SECCIÓN:** 1ASI0728

**PROFESORES:** Todos

**AUDITORES:**

       **Cabrera Ramirez, Kenyi**

       **Conde Isla, Camila**

       **Paucar Meneses, Jeremy Alión**

       **Rojas Reategui, Victor Manuel**

       **Vilcapoma Muñoz, Mauricio**

**SITE o APP A EVALUAR:** SmartPalm (Web Application & Mobile Application)

## TAREAS A EVALUAR:

El alcance de esta evaluación incluye la revisión de la usabilidad, arquitectura de información y diseño inclusivo en las siguientes tareas clave de la plataforma:

1. Proceso de registro y selección de tipo de cuenta (independiente vs. cooperativa / rol de productor vs. agrónomo).
2. Visualización del estado consolidado de las plantaciones y zonas de monitoreo en el Dashboard.
3. Consulta del detalle técnico de plantaciones y sectores (métricas de sensores IoT y niveles de criticidad).
4. Correlación entre alertas activas, visitas de campo planificadas e historial de inspecciones.
5. Interpretación y accionabilidad de alertas críticas y recomendaciones agronómicas.


## ESCALA DE SEVERIDAD:

Los errores serán puntuados tomando en cuenta la siguiente escala de severidad:

| Nivel | Descripción |
| :---: | :--- |
| 1 | Problema superficial: puede ser fácilmente superado por el usuario o ocurre con muy poca frecuencia. No necesita ser arreglado a no ser que exista disponibilidad de tiempo. |
| 2 | Problema menor: puede ocurrir un poco más frecuentemente o es un poco más difícil de superar para el usuario. Se le debería asignar una prioridad baja resolverlo de cara al siguiente release. |
| 3 | Problema mayor: ocurre frecuentemente o los usuarios no son capaces de resolverlos. Es importante que sean corregidos y se les debe asignar una prioridad alta. |
| 4 | Problema muy grave: un error de gran impacto que impide al usuario continuar con el uso de la herramienta. Es imperativo que sea corregido antes del lanzamiento. |

## TABLA RESUMEN:

| # | Problema | Escala de severidad | Heurística/Principio violada(o) |
| :-: | :--- | :-----------------: | :--- |
| 1 | Ambigüedad durante el flujo de registro al seleccionar entre cuenta independiente o cooperativa. | 3 | Match Between System and the Real World / Help and Documentation |
| 2 | Ausencia de la fecha de última visita física en las tarjetas resumen de plantaciones del Dashboard. | 2 | Visibility of System Status / Recognition Rather Than Recall |
| 3 | Falta de vinculación directa entre las alertas críticas activas y la planificación de visitas de campo. | 3 | Flexibility and Efficiency of Use / User Control and Freedom |
| 4 | Falta de contexto accionable en las alertas activas para el dueño del cultivo en la aplicación móvil. | 3 | Match Between System and the Real World / Error Prevention |
| 5 | Ausencia de indicadores de confianza o explicabilidad en las recomendaciones generadas por IA. | 3 | Visibility of System Status / Help and Documentation |

## DESCRIPCIÓN DE PROBLEMAS:

## PROBLEMA #1: Ambigüedad durante el flujo de registro al seleccionar entre cuenta independiente o cooperativa.

- **Severidad: 3 — Heurística violada: Match Between System and the Real World / Help and Documentation**
- **Problema:** Durante el flujo de onboarding y registro en la Web Application, el usuario debe elegir el tipo de perfil o modalidad de operación (productor/agrónomo independiente frente a cooperativa), pero la interfaz no explica las implicancias funcionales ni los permisos asociados a cada opción. Esto genera dudas iniciales al crear la cuenta.
- **Recomendación:** Incorporar descripciones breves debajo de cada opción de registro o tooltips informativos que detallen claramente el alcance y las capacidades de cada tipo de cuenta antes de confirmar el formulario.

## PROBLEMA #2: Ausencia de la fecha de última visita física en las tarjetas resumen de plantaciones del Dashboard.

- **Severidad: 2 — Heurística violada: Visibility of System Status / Recognition Rather Than Recall**
- **Problema:** Aunque el panel principal muestra correctamente los estados del cultivo (Óptimo, En Riesgo y Crítico), no exhibe de forma inmediata la fecha de la última inspección o visita física realizada en la plantación. El ingeniero agrónomo debe navegar hasta el historial de inspecciones para recordar cuándo fue atendido cada sector.
- **Recomendación:** Añadir el dato "Última visita: DD/MM/AAAA" directamente en la tarjeta de resumen de cada plantación dentro del Dashboard para facilitar la priorización operativa.

## PROBLEMA #3: Falta de vinculación directa entre las alertas críticas activas y la planificación de visitas de campo.

- **Severidad: 3 — Heurística violada: Flexibility and Efficiency of Use / User Control and Freedom**
- **Problema:** Al detectar una alerta crítica en un sector desde el Dashboard o el módulo de Alertas, el agrónomo no cuenta con un acceso directo para agendar una visita de campo asociada a ese evento. Debe abandonar el flujo actual, ir manualmente al módulo de visitas y volver a seleccionar la plantación y el sector afectado.
- **Recomendación:** Incluir un botón de acción contextual (ej. "+ Programar Visita") dentro del detalle de cada alerta crítica que precargue automáticamente la plantación, el sector y el motivo de la alerta en el formulario de planificación.

## PROBLEMA #4: Falta de contexto accionable en las alertas activas para el dueño del cultivo en la aplicación móvil.

- **Severidad: 3 — Heurística violada: Match Between System and the Real World / Error Prevention**
- **Problema:** En la vista de alertas de la Mobile Application, se muestran los valores fuera de rango capturados por los sensores IoT (ej. humedad del suelo o temperatura ambiental), but no se acompaña de una guía inmediata de mitigación básica para el productor mientras espera la intervención del agrónomo.
- **Recomendación:** Integrar en cada tarjeta de alerta un bloque resumido de "Acción recomendada inmediata" o vincular directamente la recomendación agronómica aprobada correspondiente al umbral excedido.

## PROBLEMA #5: Ausencia de indicadores de confianza o explicabilidad en las recomendaciones generadas por IA.

- **Severidad: 3 — Heurística violada: Visibility of System Status / Help and Documentation**
- **Problema:** Las recomendaciones agronómicas opcionales generadas automáticamente por el servicio de Inteligencia Artificial se presentan al agrónomo como un resultado estático, sin detallar las variables de telemetría (humedad, temperatura, historial de lecturas) que el modelo analizó para sugerir dicha acción, lo que dificulta validar su precisión antes de aprobarla.
- **Recomendación:** Añadir un desglose explicativo o panel de factores influyentes de la IA (ej. "Basado en la caída de humedad del 15% en los últimos 3 días") para aportar transparencia y seguridad técnica al especialista.

