# 📱 Especificación Técnica y de Diseño - Aplicación Móvil (Flutter)

Este documento detalla los lineamientos de diseño, arquitectura y funcionalidad para la aplicación móvil "Kiosco de Evaluación", asegurando una coherencia total con la plataforma web existente.

## 🎨 1. Sistema de Diseño (Design System)

La aplicación móvil debe reflejar fielmente la identidad visual de la web "PX Forge", utilizando el mismo sistema de colores y tipografía.

### **Paleta de Colores (Coherencia Web)**

| Token Web (CSS) | Valor Light | Valor Dark | Uso en Móvil |
|---|---|---|---|
| `--primary` | `#1B5E20` (Verde Bosque) | `#81C784` (Verde Claro) | Color Principal, Botones, Títulos Activos |
| `--secondary` | `#4E7D50` | `#A5D6A7` | Acentos, Bordes, Subtítulos |
| `--background` | `#FFFFFF` | `#050505` | Fondo de Pantalla (Scaffold) |
| `--surface` | `#F5F9F6` | `#101411` | Tarjetas (Cards), Modales, Inputs |
| `--container-tint` | `#E8F5E9` | `#0D3311` | Fondos de Chips, Badges |
| `--text-main` | `#1A1C19` | `#E2E3DE` | Texto Principal |
| `--text-muted` | `#424940` | `#C2C9BD` | Texto Secundario, Placeholders |
| `--error` | `#B3261E` | `#F2B8B5` | Mensajes de Error, Botones Destructivos |

### **Tipografía**
*   **Fuente Principal:** Inter (Google Fonts)
*   **Encabezados:** Bold / ExtraBold
*   **Cuerpo:** Regular / Medium

### **Componentes UI (Basados en Prototipo Figma)**

#### **A. Pantalla Principal (Home Screen)**
*   **Barra de Búsqueda:** Flotante, esquinas redondeadas (Radius 20-30), con icono de lupa y acceso a escáner QR.
*   **Chips de Categoría:** Selector horizontal.
    *   *Estado Activo:* Fondo `--primary`, Texto Blanco.
    *   *Estado Inactivo:* Fondo `--background`, Borde `--secondary`, Texto `--text-main`.
*   **Tarjetas de Proyecto (Cards):**
    *   Diseño limpio estilo "Glassmorphism" sutil o Flat Moderno.
    *   **Imagen:** Cover completo o top-half.
    *   **Badges:** Etiquetas de categoría flotantes sobre la imagen.
    *   **Info:** Título en negrita, Empresa/Autor en texto muted.
    *   **Sombra:** Suave (`BoxShadow` difuso) para dar profundidad.
*   **Bottom Navigation Bar:**
    *   Diseño minimalista.
    *   Items: "Proyectos" (Home), "Ranking" (Chart).
    *   Indicador de selección activo.

#### **B. Detalle de Proyecto**
*   **Header:** Botón "Atrás" flotante sobre la imagen o en AppBar transparente.
*   **Logotipo:** Avatar circular con borde superpuesto sobre la imagen de portada.
*   **Información Clave:** Título grande, Chip de categoría, Autores.
*   **Descripción:** Tarjeta contenedora con texto justificado/alineado.
*   **Objetivos:** Lista con viñetas (bullet points) estilizadas.
*   **Stack Tecnológico:** Chips pequeños (`Wrap` widget).
*   **Documentos:** Botón con icono de descarga/PDF (Outline Button con borde primario).
*   **Acción Principal:** Botón "Evaluar Proyecto" (Full width, Sticky en la parte inferior o flotante). Color `--primary`.

---

## 🏗️ 2. Arquitectura de Software (Clean Architecture)

Para mantener la paridad con el Backend .NET, la aplicación Flutter seguirá estrictamente **Clean Architecture** separando las responsabilidades en capas.

### **Estructura de Directorios (Propuesta)**

```
lib/
├── core/
│   ├── config/ (Theme, Rutas, Constantes)
│   ├── errors/ (Failures, Exceptions)
│   ├── network/ (Cliente HTTP, Interceptores)
│   └── usecases/ (Clase base UseCase)
├── data/
│   ├── datasources/ (RemoteDataSource - Llamadas a API)
│   ├── models/ (ProjectModel, EvaluationModel - fromJson/toJson)
│   └── repositories/ (Implementación de IRepository)
├── domain/
│   ├── entities/ (Project, Evaluation - Objetos puros de Dart)
│   ├── repositories/ (Contratos IRepository)
│   └── usecases/ (GetActiveProjects, SubmitEvaluation, etc.)
└── presentation/
    ├── bloc/ (Gestión de Estado - BLoC/Cubit recomendado)
    ├── pages/ (HomePage, ProjectDetailPage, RankingPage)
    └── widgets/ (ProjectCard, CategoryChip, CustomButton)
```

### **Patrones Clave**
*   **Repository Pattern:** Desacopla la lógica de negocio de la fuente de datos (API).
*   **Dependency Injection:** Uso de `get_it` e `injectable` para gestionar dependencias.
*   **State Management:** `flutter_bloc` o `provider` para manejar estados de UI (Loading, Loaded, Error).

---

## 🔗 3. Integración con Backend .NET

La aplicación consumirá los endpoints públicos definidos en `CHECKLIST_API_MOVIL.md`.

*   **Base URL:** `http://<IP_SERVIDOR>:5260/api` (Configurable en entorno).
*   **Headers Obligatorios:**
    *   `X-Device-UUID`: Generado al primer inicio (usar `uuid` package + `shared_preferences`).
    *   `Content-Type`: `application/json`.

### **Mapeo de Endpoints a Pantallas**

| Pantalla | Endpoint | Acción |
|---|---|---|
| **Splash / Inicio** | `GET /api/kiosk/Config/handshake` | Validar si el evento está activo y obtener versión de plantilla. |
| **Home (Proyectos)** | `GET /api/kiosk/Content/projects` | Listar tarjetas. Filtrar localmente por categoría. |
| **Detalle Proyecto** | `GET /api/kiosk/Content/projects/{id}` | Obtener info completa, docs y multimedia. |
| **Evaluación** | `GET /api/kiosk/Content/template` | Renderizar formulario dinámico. |
| **Enviar Voto** | `POST /api/kiosk/Evaluation/evaluate` | Enviar respuestas JSON. |
| **Ranking** | `GET /api/kiosk/Ranking` | Mostrar tabla de líderes (si es público). |

---

## ✅ Checklist de Implementación Móvil

1.  [ ] **Configuración Inicial:** Crear proyecto Flutter, definir estructura de carpetas, configurar temas (Light/Dark).
2.  [ ] **Capa Data:** Implementar Modelos (DTOs) y DataSources (Dio/Http).
3.  [ ] **Capa Domain:** Definir Entidades y Casos de Uso.
4.  [ ] **UI - Home:** Maquetar pantalla principal, buscador y lista horizontal de categorías.
5.  [ ] **UI - Detalle:** Maquetar pantalla de detalle con scroll parallax o slivers.
6.  [ ] **Lógica:** Conectar BLoC/Provider para fetching de datos real desde la API.
7.  [ ] **Funcionalidad:** Implementar escaneo QR (opcional por ahora) y envío de evaluaciones.
