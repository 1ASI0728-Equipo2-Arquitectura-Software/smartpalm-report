# 6.4. Diseño UX/UI de las aplicaciones

## 6.4.4. Diagramas de flujo de usuario de las aplicaciones

Los siguientes diagramas completan los recorridos principales de SmartPalm. Cada flujo se vincula con las pantallas de alta fidelidad e incluye el camino satisfactorio y las respuestas ante credenciales inválidas, permisos insuficientes, falta de datos, errores de servicio o trabajo sin conexión.

### Flujos de usuario de la aplicación web

#### Autenticarse y acceder al panel principal

**Objetivo del usuario:** acceder de forma segura a la información permitida por su rol y organización.

| Inicio de sesión | Panel principal |
|---|---|
| ![Vista web del inicio de sesión](../../assets/chapter6/applications-ux-ui-design/web-mock-ups/Login.png) | ![Vista web del panel principal](../../assets/chapter6/applications-ux-ui-design/web-mock-ups/Dashboard.png) |

```mermaid
flowchart TD
    A["Abrir SmartPalm Web"] --> B["Ingresar credenciales"]
    B --> C{"Credenciales válidas?"}
    C -- No --> D["Mostrar error de validación"]
    D --> B
    C -- Sí --> E{"Rol y organización activos?"}
    E -- No --> F["Mostrar restricción de acceso y opción de soporte"]
    E -- Sí --> G["Cargar plantaciones permitidas"]
    G --> H["Mostrar panel principal y última actualización"]
```

El recorrido esperado termina en el panel principal. Las credenciales inválidas devuelven al formulario, mientras que una cuenta inactiva o una asignación incorrecta de organización impide el acceso sin exponer datos ajenos.

#### Monitorear y priorizar una plantación

**Objetivo del usuario:** identificar la plantación que requiere atención y revisar su condición.

| Panel principal | Cartera de plantaciones | Alertas |
|---|---|---|
| ![Panel principal para el monitoreo](../../assets/chapter6/applications-ux-ui-design/web-mock-ups/Dashboard.png) | ![Cartera de plantaciones](../../assets/chapter6/applications-ux-ui-design/web-mock-ups/Plantaciones.png) | ![Alertas para la priorización](../../assets/chapter6/applications-ux-ui-design/web-mock-ups/Alertas.png) |

```mermaid
flowchart TD
    A["Abrir panel principal"] --> B["Revisar indicadores y alertas críticas"]
    B --> C["Abrir cartera de plantaciones"]
    C --> D["Seleccionar plantación"]
    D --> E{"Hay datos procesados?"}
    E -- Sí --> F["Revisar tendencias, zonas y alertas"]
    E -- No --> G["Mostrar estado vacío o última actualización disponible"]
    G --> H["Reintentar o revisar estado de dispositivos"]
    F --> I["Priorizar la siguiente acción"]
```

El usuario puede distinguir la información actual del último valor procesado. La ausencia de información no se presenta como un valor cero; en su lugar, la interfaz ofrece revisar el estado del dispositivo o volver a intentar la consulta.

#### Resolver una alerta mediante una recomendación

**Objetivo del usuario:** analizar una condición de riesgo y convertirla en una acción agronómica.

| Alertas | Recomendaciones |
|---|---|
| ![Vista web de alertas](../../assets/chapter6/applications-ux-ui-design/web-mock-ups/Alertas.png) | ![Vista web de recomendaciones](../../assets/chapter6/applications-ux-ui-design/web-mock-ups/Recomendaciones.png) |

```mermaid
flowchart TD
    A["Abrir alertas"] --> B["Filtrar por severidad y estado"]
    B --> C["Seleccionar alerta"]
    C --> D["Revisar evidencia y contexto de la plantación"]
    D --> E{"Puede gestionar recomendaciones?"}
    E -- No --> F["Leer recomendación disponible"]
    E -- Sí --> G["Crear o editar recomendación"]
    G --> H{"Información completa?"}
    H -- No --> I["Señalar campos pendientes"]
    I --> G
    H -- Sí --> J["Publicar recomendación"]
    J --> K["Notificar al palmicultor asignado"]
```

El agrónomo puede crear y publicar una recomendación cuando está autorizado. Los demás roles mantienen acceso de solo lectura y conservan la misma evidencia y contexto.

#### Registrar una inspección y generar un reporte

**Objetivo del usuario:** registrar el trabajo de campo e incorporar sus resultados al historial de la plantación.

| Cartera de plantaciones | Reportes |
|---|---|
| ![Selección de la plantación](../../assets/chapter6/applications-ux-ui-design/web-mock-ups/Plantaciones.png) | ![Vista web de reportes](../../assets/chapter6/applications-ux-ui-design/web-mock-ups/Reportes.png) |

```mermaid
flowchart TD
    A["Seleccionar plantación"] --> B["Crear inspección de campo"]
    B --> C["Ingresar observaciones y evidencia"]
    C --> D{"Hay conexión disponible?"}
    D -- Sí --> E["Validar y guardar inspección"]
    D -- No --> F["Guardar como sincronización pendiente"]
    F --> G["Recuperar conexión y sincronizar"]
    G --> E
    E --> H{"Procesamiento correcto?"}
    H -- No --> I["Mostrar opción de reintento sin perder datos"]
    I --> E
    H -- Sí --> J["Actualizar historial y reporte"]
```

El flujo protege la información capturada cuando se interrumpe la conectividad e identifica claramente la inspección como pendiente hasta que el servicio de gestión técnica de campo la confirme.

#### Activar una suscripción y registrar un dispositivo

**Objetivo del usuario:** habilitar el servicio y asociar un dispositivo IoT con la plantación correcta.

| Suscripción | Dispositivos |
|---|---|
| ![Gestión de la suscripción](../../assets/chapter6/applications-ux-ui-design/web-mock-ups/Suscripcion.png) | ![Gestión de dispositivos](../../assets/chapter6/applications-ux-ui-design/web-mock-ups/Dispositivos.png) |

```mermaid
flowchart TD
    A["Abrir gestión de dispositivos"] --> B{"Suscripción activa?"}
    B -- No --> C["Revisar plan disponible"]
    C --> D["Completar proceso de suscripción"]
    D --> E{"Pago o activación confirmados?"}
    E -- No --> C
    E -- Sí --> F["Registrar identificador del dispositivo"]
    B -- Sí --> F
    F --> G["Asociar dispositivo con la plantación"]
    G --> H{"Dispositivo verificado?"}
    H -- No --> I["Mostrar indicaciones de verificación"]
    I --> F
    H -- Sí --> J["Mostrar estado y lecturas del dispositivo"]
```

Este recorrido evita asociar dispositivos con cuentas inactivas y confirma tanto la organización como la plantación antes de presentar la telemetría.

### Flujos de usuario de la aplicación móvil

#### Iniciar sesión o continuar sin conexión

**Objetivo del usuario:** ingresar a la aplicación desde el campo con o sin conectividad.

![Flujo móvil del inicio de sesión](../../assets/chapter6/applications-ux-ui-design/mobile-user-flows/login.png)

```mermaid
flowchart TD
    A["Abrir aplicación móvil"] --> B{"Hay conexión disponible?"}
    B -- Sí --> C["Ingresar credenciales"]
    C --> D{"Credenciales válidas?"}
    D -- No --> E["Mostrar error y opción de recuperación"]
    E --> C
    D -- Sí --> F["Sincronizar datos permitidos"]
    F --> G["Abrir panel principal"]
    B -- No --> H{"Hay una sesión local autenticada?"}
    H -- No --> I["Explicar que se requiere autenticación en línea"]
    H -- Sí --> J["Continuar con datos almacenados"]
    J --> K["Mostrar modo sin conexión y última actualización"]
```

El acceso sin conexión solo está disponible para una sesión autenticada previamente y nunca amplía los permisos que el usuario ya tiene asignados.

#### Revisar el detalle de una plantación

**Objetivo del usuario:** consultar la condición y las tendencias de una plantación seleccionada.

![Flujo móvil del detalle de una plantación](../../assets/chapter6/applications-ux-ui-design/mobile-user-flows/detalles.png)

```mermaid
flowchart TD
    A["Abrir panel principal"] --> B["Seleccionar plantaciones"]
    B --> C["Elegir plantación"]
    C --> D["Abrir detalle de la plantación"]
    D --> E{"Hay datos recientes?"}
    E -- Sí --> F["Mostrar indicadores, zonas y tendencias"]
    E -- No --> G["Mostrar últimos datos sincronizados y su fecha"]
    F --> H["Abrir alertas o sensores"]
    G --> I["Reintentar cuando regrese la conexión"]
```

La interfaz hace explícita la vigencia de los datos para que el palmicultor no confunda la información almacenada con una lectura en tiempo real.

#### Atender una alerta y revisar su recomendación

**Objetivo del usuario:** comprender una advertencia y seguir la acción agronómica propuesta.

| Alertas | Detalle de la plantación |
|---|---|
| ![Vista móvil de alertas](../../assets/chapter6/applications-ux-ui-design/mobile-mock-ups/alertas.png) | ![Vista móvil del detalle de la plantación](../../assets/chapter6/applications-ux-ui-design/mobile-mock-ups/detalles.png) |

```mermaid
flowchart TD
    A["Recibir o abrir alerta"] --> B["Revisar severidad y zona afectada"]
    B --> C{"Detalle disponible?"}
    C -- No --> D["Conservar alerta y ofrecer actualización"]
    C -- Sí --> E["Revisar evidencia"]
    E --> F{"Recomendación publicada?"}
    F -- No --> G["Mostrar recomendación pendiente"]
    F -- Sí --> H["Abrir recomendación"]
    H --> I["Revisar acción y responsable"]
    I --> J["Volver al monitoreo de la plantación"]
```

La alerta permanece disponible cuando su detalle o recomendación todavía se está procesando, reflejando la comunicación asíncrona entre los servicios.

#### Revisar sensores y sincronizar acciones pendientes

**Objetivo del usuario:** verificar el estado de los dispositivos y conservar las acciones de campo cuando la red es inestable.

![Flujo móvil de sensores](../../assets/chapter6/applications-ux-ui-design/mobile-user-flows/sensores.png)

```mermaid
flowchart TD
    A["Abrir sensores"] --> B["Seleccionar dispositivo"]
    B --> C["Revisar estado, batería y última lectura"]
    C --> D{"Datos del dispositivo vigentes?"}
    D -- Sí --> E["Continuar monitoreo"]
    D -- No --> F["Mostrar estado desactualizado o desconectado"]
    F --> G["Revisar indicaciones para resolver el problema"]
    G --> H{"Conexión restablecida?"}
    H -- No --> I["Conservar acciones pendientes localmente"]
    H -- Sí --> J["Sincronizar acciones pendientes"]
    J --> K{"Sincronización correcta?"}
    K -- No --> I
    K -- Sí --> E
```

Las acciones pendientes permanecen visibles hasta que la sincronización finaliza correctamente, evitando que el usuario asuma que una operación ya llegó al backend.

### Cobertura de los flujos de usuario

| Perfil de usuario | Objetivos principales representados | Contextos delimitados relacionados |
|---|---|---|
| Agrónomo | Monitorear plantaciones, resolver alertas, publicar recomendaciones, registrar inspecciones y generar reportes | Panel de monitoreo de cultivos, alertas y notificaciones, recomendaciones agronómicas, gestión técnica de campo |
| Palmicultor | Consultar el estado del cultivo, revisar alertas y recomendaciones, verificar sensores y trabajar sin conexión | Procesamiento de datos de sensores, panel de monitoreo de cultivos, alertas y notificaciones, gestión de dispositivos IoT |
| Administrador de la organización | Gestionar acceso, suscripción y asociación de dispositivos | Gestión de suscripciones y usuarios, gestión de dispositivos IoT |
