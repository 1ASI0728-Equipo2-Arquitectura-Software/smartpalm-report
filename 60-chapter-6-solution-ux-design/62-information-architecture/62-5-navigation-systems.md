#### 6.2.5. Navigation Systems

El sistema de navegación de SmartPalm se basa en una arquitectura jerárquica persistente con apoyos de navegación contextual y directa, estructurada de forma diferenciada pero coherente entre las plataformas web y móvil:

##### Navegación Web (Escritorio / Tablet):

- Barra Lateral Persistente (Sidebar): Menú vertical estático ubicado a la izquierda que alberga los accesos primarios (Dashboard, Cartera de plantaciones, Alertas, Recomendaciones, Reportes, Inspecciones, Mi suscripción, Mi perfil).

- Encabezado de Contexto (Top Bar): Muestra el perfil del usuario activo (ej. Ing. Roberto Sánchez Paredes), la ubicación dentro de la jerarquía de la app y el centro unificado de notificaciones inmediatas.

##### Navegación Móvil (Smartphone):

- Barra de Navegación Inferior (Bottom Navigation Bar): Accesos directos a las tareas más frecuentes en campo (Inicio/Dashboard, Alertas, Inspecciones, Perfiles).

- Flujos Simplificados: Reducción de la profundidad de clics (Click depth) para ejecutar acciones críticas en un máximo de 2 toques.

##### Principios de Navegación Aplicados

### Visibilidad del Estado Actual
El módulo activo se resalta visualmente en la barra lateral con tonos diferenciados y bordes redondeados.

### Navegación Retrospectiva (Breadcrumbs / Botón Volver)
En vistas detalladas (como en la lectura de un Reporte técnico o una Inspección específica), se incluyen enlaces directos de retorno (`← Volver a reportes`, `← Volver a inspecciones`) para evitar desorientación.

### Priorización de Incidencias
Los indicadores numéricos rojos en los iconos de notificación e ítems de menú informan la presencia de alertas críticas pendientes sin necesidad de entrar a la sección.
