# Capítulo VII: Product Implementation, Validation & Deployment

## 7.1. Software Configuration Management

Este capítulo documenta la configuración técnica utilizada por el equipo TempWise para implementar y desplegar los componentes trabajados durante el primer sprint de SmartPalm: el desarrollo del backend en microservicios, la Web Application, las aplicaciones embedded para los dispositivos y el Edge API. El objetivo de esta sección es dejar evidencia clara de las herramientas, repositorios, convenciones y ambientes usados para construir esta primera versión del producto, alineando la planeación del sprint y el backlog a estos objetivos técnicos.

### 7.1.1. Software Development Environment Configuration

Durante el sprint, el equipo se enfocó en los frentes de implementación clave del sistema. Primero, el desarrollo del backend estructurado en microservicios, asegurando la lógica de negocio y la integración de los servicios core. Segundo, la Web Application, desarrollada para permitir la navegación inicial de los usuarios, dashboard, gestión de plantaciones, alertas, recomendaciones, reportes, dispositivos y suscripciones. Tercero, el desarrollo de las aplicaciones embedded orientadas a los dispositivos de campo y la configuración del Edge API para la gestión de la capa de borde. Cabe destacar que el proyecto no utiliza "mock-apis", por lo que toda la arquitectura descrita opera directamente sobre los microservicios y repositorios oficiales de la organización, de los cuales se puede extraer el historial de commits y sus enlaces correspondientes.

| Category | Tool / Platform | Usage in Sprint 1 | Reference |
|---|---|---|---|
| Project Management | Trello | Organización de tareas, historias de usuario y seguimiento del sprint. | https://trello.com/b/HSjBsXFx/grupo-2-fundamentos-de-arquitectura-de-software |
| Source Code Management | Git + GitHub | Control de versiones, ramas, commits y colaboración del equipo. | https://github.com/orgs/1ASI0728-Equipo2-Arquitectura-Software/repositories|
| Report Documentation | Markdown + GitHub | Documentación del avance del proyecto bajo enfoque Docs-as-Code. | https://github.com/1ASI0728-Equipo2-Arquitectura-Software/smartpalm-report |
| UX/UI Design | Figma | Diseño de wireframes, mock-ups y flujos de Landing Page y Web Application. |https://www.figma.com/design/bFDv7p60jPElSFuoSRZF1H/WebApp?node-id=0-1&p=f |
| Collaborative Modeling | Miro | Modelado colaborativo previo de procesos y dominio del producto. | https://miro.com/app/board/uXjVHdJ_3Wo=/?share_link_id=547546845690 |
| Web Application Development | Angular | Desarrollo de la Web Application de SmartPalm. | |
| Code Editor | Visual Studio Code | Edición de código fuente, archivos Markdown y configuración de proyecto. | https://code.visualstudio.com |
| Static Site Deployment | Netlify | Publicación del Landing Page. | |
| Web App Deployment | Cloudflare Pages | Publicación de la Web Application. |  |

### 7.1.2. Source Code Management

El equipo utiliza Git como sistema de control de versiones y GitHub como plataforma de alojamiento remoto. Para el desarrollo, los repositorios relevantes corresponden al informe del proyecto, Landing Page, Web Application, Web Service, Mobile Application, Edge Service, Embedded Application y Mock API.

**GitHub Repositories**

| Product | Repository | Purpose | Status |
|---|---|---|---|
| Project Report | `smartpalm-report` | Contiene el informe, anexos y evidencias documentales del proyecto. | https://github.com/1ASI0728-Equipo2-Arquitectura-Software/smartpalm-report|
| Landing Page | `website` | Contiene el sitio público de SmartPalm con propuesta de valor, segmentos, beneficios, pricing y equipo. | https://github.com/upc-202601-1asi0572-6779-teamwise/website |
| Web Application | `webapp-test` | Contiene la Web Application principal, incluyendo los bounded contexts y componentes compartidos implementados por el equipo. | https://github.com/1ASI0728-Equipo2-Arquitectura-Software/SmartPalm-WebApp |
| Web Service | `webservice` | Contiene el RESTful API desarrollado con ASP.NET Core, los bounded contexts de backend, persistencia y documentación de endpoints mediante Swagger. | https://github.com/1ASI0728-Equipo2-Arquitectura-Software/SmartPalm.ApiGateway |
| Mobile Application | `mobileapp` | Contiene la aplicación móvil desarrollada con Flutter para permitir la consulta y operación de funcionalidades de SmartPalm desde campo. | https://github.com/1ASI0728-Equipo2-Arquitectura-Software/SmartPalm-MobileApp |
| Edge Service | `edgeservice` | Contiene el Edge API desarrollado con Python para gestionar la comunicación y sincronización de datos entre el dispositivo IoT y la plataforma cloud. | https://github.com/1ASI0728-Equipo2-Arquitectura-Software/edge-api |
| Embedded Application | `embeddedapp` | Contiene el código de la aplicación embebida ejecutada en el dispositivo IoT para obtener y transmitir lecturas sensoriales. |https://github.com/1ASI0728-Equipo2-Arquitectura-Software/edge-node |

**GitFlow Workflow**

El flujo de trabajo se organiza con ramas principales y ramas por funcionalidad. Esta estructura permite separar el código estable, la integración de avances y el desarrollo de funcionalidades específicas.

| Branch Type | Convention | Purpose |
|---|---|---|
| Main Branch | `main` | Contiene versiones estables o entregables finales. |
| Development Branch | `develop` | Integra los avances antes de pasar a una versión estable. |
| Feature Branches | `feature/<description>` | Agrupan funcionalidades o secciones específicas del producto. |
| Deployment Branch | `deploy` | Agrupa ajustes de publicación y configuración de despliegue cuando corresponde. |


**Conventional Commits**

Los commits siguen una estructura basada en Conventional Commits para mantener trazabilidad.

| Type | Usage | Example |
|---|---|---|
| `feat` | Nueva funcionalidad. | `feat(dashboard): replace placeholder with real dashboard and 5 widgets` |
| `fix` | Corrección de errores. | `fix(auth): improve login and registration feedback` |
| `docs` | Cambios de documentación. | `docs: update chapter 6 evidence` |
| `refactor` | Mejora interna sin cambiar la funcionalidad esperada. | `refactor(alerts): redesign list with left-border severity` |
| `config` | Configuración de entorno o despliegue. | `config(cloudflare): add SPA fallback` |

### 7.1.3. Source Code Style Guide & Coding Conventions

El equipo define convenciones de código para mantener legibilidad, consistencia y trazabilidad entre los productos implementados durante los sprints.

| Element | Convention | Example |
|---|---|---|
| Angular Components | PascalCase | `DashboardComponent`, `PlantationDetailComponent` |
| Services | PascalCase with `Service` suffix | `PlantationService`, `AlertService` |
| Methods and Variables | camelCase | `getActiveAlerts()`, `currentPlantation` |
| Constants | UPPER_SNAKE_CASE | `MAX_VISIBLE_ALERTS` |
| Files and Folders | kebab-case | `plantation-detail.component.ts` |
| Routes | Lowercase route paths | `/dashboard`, `/plantaciones`, `/alertas` |
| Branches | kebab-case | `feature/dashboard-redesign` |
| Commits | English and imperative | `feat(subscription): add role-aware plans` |

**General Rules**

- El código fuente, nombres técnicos y commits se redactan en inglés.
- Los textos visibles al usuario pueden estar en español cuando formen parte de la experiencia de SmartPalm.
- Las funcionalidades se organizan por módulo: `auth`, `dashboard`, `plantations`, `devices`, `alerts`, `recommendations`, `reports`, `inspections`, `profile` y `subscription`.


**Project Boards and Design References**

| Resource | URL |
|---|---|
| Trello Board | https://trello.com/b/HSjBsXFx/grupo-2-fundamentos-de-arquitectura-de-software |
| Figma WebApp Design | https://www.figma.com/design/bFDv7p60jPElSFuoSRZF1H/WebApp?node-id=0-1&p=f |


### 7.1.4. Software Deployment Configuration

La configuración de despliegue del Sprint 1 considera únicamente los artefactos implementados y publicados en esta iteración o pruebas de integración: Landing Page, Web Application y Mock API.

| Artifact | Platform | Public URL | Sprint 1 Status |
|---|---|---|---|
| Landing Page | Netlify | https://smart-palm.netlify.app/ | Deployed |
| Web Application | Cloudflare Pages | https://github.com/1ASI0728-Equipo2-Arquitectura-Software/SmartPalm-WebApp | - |



**Deployment Configuration Summary**

| Artifact | Configuration |
|---|---|
| Landing Page | Publicación estática en Netlify desde el proyecto del Landing Page. |
| Web Application | Publicación de aplicación Angular en Cloudflare Pages. |





