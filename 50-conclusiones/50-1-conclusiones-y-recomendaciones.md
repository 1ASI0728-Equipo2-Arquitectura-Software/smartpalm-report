## Conclusiones y Recomendaciones

### Conclusiones

El desarrollo del TB1 del proyecto SmartPalm permitió consolidar la base de ingeniería de una solución de monitoreo inteligente de cultivos de palma aceitera para la Amazonia peruana. La investigación de los segmentos objetivo confirmó la validez de los planteamientos del proceso Lean UX: la gestión reactiva del palmicultor y las restricciones logísticas del ingeniero agrónomo son condiciones reales y complementarias que generan una brecha de productividad documentada de hasta USD 1 700 por hectárea al año.

A partir de esa problemática, el equipo formalizó el alcance del producto mediante 46 User Stories y 26 Technical Stories con criterios de aceptación en Gherkin, priorizadas en un Product Backlog orientado al valor de negocio y coherente con los segmentos definidos. Estas historias constituyeron el insumo de las dos disciplinas de diseño arquitectónico desarrolladas en el informe.

En el diseño estratégico de dominio se aplicó Domain-Driven Design para descomponer el sistema en siete bounded contexts (IoT Device Management, Sensor Data Processing, Alert & Notification, Agronomic Recommendation, Crop Monitoring Dashboard, Field Technical Management y Subscription & User Management), clasificados por su aporte al negocio y relacionados mediante patrones de context mapping. Sobre esa base, el proceso Attribute-Driven Design permitió derivar los drivers funcionales, de calidad y de restricción, evaluar patrones candidatos y refinar escenarios de calidad medibles que sustentan las decisiones de arquitectura.

La arquitectura de software resultante, documentada con el modelo C4 (System Landscape, Context, Container y Deployment) y elaborada en Structurizr, adopta un enfoque de microservicios alineado con los bounded contexts, con propiedad de datos por servicio, comunicación asíncrona mediante broker en la ruta crítica, un Edge API para la operación offline y despliegue independiente sobre servicios cloud. La aplicación de GitFlow y Conventional Commits, junto con una organización del informe por secciones y ramas, facilitó la colaboración y la trazabilidad entre requisitos, decisiones de diseño e implementación.

Al cierre del TB1, la solución cuenta con una base arquitectónica y de requisitos sólida y verificable. Quedan pendientes para las siguientes entregas el diseño táctico por bounded context, el diseño de experiencia de usuario, la implementación y el despliegue de los productos digitales, así como la validación empírica de las hipótesis planteadas en el proceso Lean UX.

### Recomendaciones

1. Completar las entrevistas de validación con usuarios representativos de ambos segmentos para contrastar las hipótesis del proceso Lean UX con evidencia directa y no solo con el diseño de la solución.
2. Desarrollar el diseño táctico (Capítulo V) por cada bounded context, detallando las capas de dominio, interfaz, aplicación e infraestructura, así como los diagramas de componentes, clases y base de datos.
3. Definir las guías de estilo, la arquitectura de información y el diseño de UI/UX (Capítulo VI) de forma consistente entre el Landing Page, la aplicación web y la aplicación móvil.
4. Implementar los productos digitales priorizando el Product Backlog por valor de negocio, comenzando por el Landing Page y las capacidades centrales de monitoreo, alertas y recomendaciones.
5. Mantener actualizado el Registro de Versiones, el Collaboration Insights y el Student Outcome en cada entrega, reemplazando los enlaces provisionales por los definitivos.
