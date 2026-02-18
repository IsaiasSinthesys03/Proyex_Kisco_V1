# Modelo de Datos del Kiosco de Evaluación

Este documento detalla la estructura lógica de los datos (Entidades) implementadas en el Backend (.NET/MongoDB).

## Diagrama de Clases (UML)

```mermaid
classDiagram
    direction TB

    %% Entidades Principales
    class Project {
        +ObjectId Id
        +string Title
        +string Description
        +string Category
        +string CoverImageUrl
        +string IconUrl
        +string VideoUrl
        +string Status
        +List~ProjectDocument~ Documents
        +ProjectStats Stats
    }

    class ProjectDocument {
        +string Title
        +string Url
        +string Type
    }

    class Evaluation {
        +ObjectId Id
        +ObjectId ProjectId
        +string DeviceUuid
        +string TemplateVersion
        +List~Answer~ Answers
        +string Comment
        +DateTime ClientTimestamp
    }

    class EvaluationTemplate {
        +ObjectId Id
        +string Version
        +bool IsActive
        +List~TemplateSection~ Sections
    }

    class User {
        +ObjectId Id
        +string Email
        +string Role
    }

    class GlobalSettings {
        +ObjectId Id
        +string EventName
        +bool IsVotingEnabled
    }

    %% Entidades Futuras (Planificadas)
    class AuditLog:::future {
        +ObjectId Id
        +string Action
        +string EntityChanged
        +string UserId
        +DateTime Timestamp
        +string OldValue
        +string NewValue
    }

    class Category:::future {
        +ObjectId Id
        +string Name
        +string Slug
        +string ColorCode
    }

    class MediaGallery:::future {
        +ObjectId Id
        +ObjectId ProjectId
        +string Url
        +string Type
        +bool IsHero
    }

    %% Relaciones
    Project *-- ProjectDocument : "Contiene"
    Evaluation --> Project : "Evalúa a (ProjectId)"
    Evaluation --> EvaluationTemplate : "Usa versión de"
    MediaGallery --> Project : "Pertenece a"
    Project --> Category : "Clasificado en (Ref)"

    %% Estilos para distinguir lo futuro
    classDef future fill:#f9f,stroke:#333,stroke-width:2px,stroke-dasharray: 5 5;
```

## Diccionario de Datos

### 1. `Project` (Proyecto)
Representa un proyecto expuesto en el kiosco.
- **Videos:** Se almacenan en el campo `VideoUrl`.
- **Documentos:** Lista de archivos adjuntos (PDFs, PPTs) en la colección `Documents`.
- **Multimedia:** `CoverImageUrl` (Portada) e `IconUrl` (Logotipo).

### 2. `Evaluation` (Reseña/Voto)
Representa la evaluación realizada por un usuario.
- **Reseña:** El campo `Comment` almacena la opinión textual del usuario.
- **Puntuación:** La lista `Answers` contiene los valores numéricos de cada pregunta.

### 3. `ProjectDocument` (Documento)
Clase anidada dentro de `Project` para manejar archivos adjuntos.
- `Type`: Puede ser "pdf", "enlace", "resumen", etc.

## Entidades Futuras (Planificadas) - Fase 2

Estas entidades están definidas en los requerimientos pero se implementarán en la siguiente fase de desarrollo.

### 4. `AuditLog` (Historial de Cambios)
*Requerimiento: RF-WEB-15 / RF-BACK-15*
Registro inmutable de todas las acciones administrativas (creación, edición, eliminación) para fines de seguridad y auditoría.
- **Action:** Tipo de cambio (CREATE, UPDATE, DELETE).
- **EntityChanged:** Qué se modificó (ej. "Project: 123").
- **OldValue/NewValue:** Snapshots para revertir cambios.

### 5. `Category` (Categoría)
*Requerimiento: RF-FRONT-03*
Actualmente el campo `Category` en `Project` es un string simple. En el futuro, se normalizará a su propia colección para permitir:
- Gestión dinámica de categorías desde el Dashboard.
- Asignación de colores (`ColorCode`) para los filtros de la UI.

### 6. `MediaGallery` (Galería Multimedia Avanzada)
*Requerimiento: RF-FRONT-01 / RF-BACK-02*
Aunque `Project` ya tiene `VideoUrl` e `ImageCoverUrl`, esta entidad permitirá:
- Múltiples videos o imágenes por proyecto.
- Marcar un recurso específico como "Hero" (Principal).
- Metadatos adicionales (Créditos, Leyendas).
