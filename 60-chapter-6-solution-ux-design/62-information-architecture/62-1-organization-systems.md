# 6.2. Information Architecture

La arquitectura de información de SmartPalm fue concebida para garantizar un acceso ágil, claro y estructurado a los datos agronómicos, telemetría IoT, eventos de alerta y herramientas de gestión técnica. Se diseñó un entorno de navegación altamente intuitivo adaptado a los dos perfiles principales de usuario: productores agrícolas (orientados a la consulta rápida en campo y recepción de diagnósticos) e ingenieros agrónomos (enfocados en la supervisión analítica de múltiples parcelas, auditoría de campo y emisión de recomendaciones).

La estructura organizativa priorizó la reducción de la fricción y complejidad operativa, optimizando los flujos de trabajo para permitir la localización inmediata de datos críticos provenientes de la red de sensores (temperatura, humedad, pH), condiciones agrometeorológicas, estado sanitario de las plantaciones y generación de reportes técnicos.

Asimismo, la solución adopta una arquitectura modular y escalable. Esto asegura la capacidad de incorporar progresivamente nuevas capacidades —como modelos predictivos avanzados, integración de nuevos nodos IoT o módulos administrativos adicionales— sin distorsionar los patrones de navegación ni afectar la curva de aprendizaje de los usuarios.

---

#### 6.2.1. Organization Systems

El sistema de organización de SmartPalm emplea un esquema híbrido que combina una estructura jerárquica basada en roles con un agrupamiento funcional de contenidos. Esta estrategia categoriza las herramientas y datos según la frecuencia de uso, el nivel de criticidad operativa y el contexto de interacción del usuario.

A partir del análisis de flujos y mockups de la interfaz, la plataforma consolida sus funciones en los siguientes módulos principales:

- Dashboard Principal (Centro de Operaciones): Panel centralizado que sintetiza la salud global de los cultivos, tendencias métricas en tiempo real y el resumen de alertas activas.

- Cartera de Plantaciones: Vista general y detallada para la gestión, geolocalización y monitoreo parcelado por lotes y fundos.

- Alertas: Centro de gestión de incidencias que clasifica anomalias operativas y ambientales por niveles de gravedad (Críticas y Advertencias).

- Recomendaciones (IA / Diagnóstico Agronómico): Módulo de prescripciones técnicas automatizadas e intervenciones sugeridas para mitigar riesgos en los cultivos.

- Reportes: Módulo para la consulta, generación y exportación (PDF/Excel) de informes de desempeño técnico mensual y diagnóstico agroeconómico.

- Inspecciones (de Campo): Registro analítico y bitácora de visitas presenciales, hallazgos, fotos y estado operativo de las parcelas.

- Mi Suscripción y Gestión de Planes: Panel de administración comercial del servicio (planes Básico, Profesional, Enterprise) para el control de limites de recursos, parcelas gestionadas y facturación.

- Configuración y Mi Perfil: Gestión de credenciales y roles de usuario

La jerarquía organizativa garantiza que la telemetría en tiempo real y las notificaciones de emergencia estén accesibles directamente desde el nivel superior del sistema, minimizando los tiempos de respuesta frente a eventualidades agrícolas que puedan comprometer la productividad del cultivo.

---
