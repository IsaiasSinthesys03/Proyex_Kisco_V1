# 🗺️ Roadmap de Desarrollo Móvil (Flutter)

Este documento sirve como guía paso a paso para la construcción de la aplicación móvil "Kiosco de Evaluación", asegurando la integración correcta con el Backend .NET y la fidelidad visual con el diseño web.

## 📅 Fase 1: Fundamentos y Configuración

- [ ] **1.1. Configuración de Entorno**
    - [ ] Verificar instalación de Flutter SDK y Dart.
    - [ ] Asegurar que el dispositivo/emulador tenga acceso a la API local (10.0.2.2 para Android o IP de LAN).

- [ ] **1.2. Gestión de Dependencias (pubspec.yaml)**
    - [ ] Confirmar paquetes clave: `provider`, `http` (o `dio`), `google_fonts`, `uuid`, `shared_preferences`.
    - [ ] Instalar `flutter_svg` si se usan iconos vectoriales personalizados.

- [ ] **1.3. Capa Core (Infraestructura)**
    - [ ] Definir `AppColors` con la paleta extraerda de la Web (`#1B5E20`, `#81C784`, etc.).
    - [ ] Configurar `ThemeData` para Light y Dark mode usando Google Fonts (Inter).
    - [ ] Implementar servicio de almacenamiento local (`SharedPreferences`) para persistir el `device_uuid`.

## 📱 Fase 2: UI y Navegación (Prototipo UX)

- [ ] **2.1. Pantalla Home (Proyectos)**
    - [ ] Crear `ProjectCard` widget (Imagen, Título, Categoría).
    - [ ] Implementar `CategorySelector` (Chips horizontales).
    - [ ] Maquetar la barra de búsqueda y el switch de modo oscuro.
    - [ ] Configurar `BottomNavigationBar` para navegar entre "Proyectos" y "Ranking".

- [ ] **2.2. Pantalla Detalle de Proyecto**
    - [ ] Diseñar layout con `SliverAppBar` o Header personalizado.
    - [ ] Crear secciones de información: Descripción, Objetivos, Stack.
    - [ ] Añadir botón "Evaluar Proyecto" flotante o sticky footer.
    - [ ] Implementar descarga/apertura de documentos PDF.

## 🔌 Fase 3: Integración con Backend (Data & Domain)

- [ ] **3.1. Modelos de Datos (Data Layer)**
    - [ ] Crear `ProjectModel` con `fromJson`/`toJson` (mapeado a `ProjectDto` del backend).
    - [ ] Crear `EvaluationModel` para el envío de votos.

- [ ] **3.2. Repositorios (Domain Layer)**
    - [ ] Definir interfaz `IProjectRepository`.
    - [ ] Definir interfaz `IEvaluationRepository`.
    - [ ] Implementar `ProjectRepositoryImpl` usando `http`/`dio`.

- [ ] **3.3. Gestión de Estado (Presentation Layer)**
    - [ ] Crear `Providers` o `BLoCs` para:
        - `ProjectsProvider`: Lista de proyectos, filtro por categoría, búsqueda.
        - `EvaluationProvider`: Manejo del formulario de evaluación.
        - `ConfigProvider`: Handshake inicial y verificación de estado de votación.

## 🚀 Fase 4: Funcionalidad de Evaluación

- [ ] **4.1. Formulario Dinámico**
    - [ ] Consumir `GET /api/kiosk/Content/template`.
    - [ ] Renderizar preguntas según el tipo (estrellas, escala, texto).

- [ ] **4.2. Envío y Validación**
    - [ ] Validar respuestas obligatorias.
    - [ ] Enviar `POST /api/kiosk/Evaluation/evaluate` con el `device_uuid`.
    - [ ] Manejar errores (ej. "Ya votaste", "Votación cerrada").

## 🏁 Fase 5: Pulido y Despliegue

- [ ] **5.1. Ranking en Tiempo Real (Opcional)**
    - [ ] Consumir `GET /api/kiosk/Ranking`.
    - [ ] Integrar SignalR (si se reactiva en el backend) o Polling.

- [ ] **5.2. Pruebas Finales**
    - [ ] Verificar flujo completo: Login (Anónimo) -> Ver -> Evaluar -> Ranking.
    - [ ] Validar modo offline (si aplica) o manejo de errores de red.
