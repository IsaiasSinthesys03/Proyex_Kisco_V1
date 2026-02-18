# Documentación de la API del Kiosco de Evaluación

Esta documentación detalla la implementación de la API RESTful construida con .NET 8 y MongoDB, siguiendo los principios de **Clean Architecture**.

## 🏗️ Arquitectura

La solución está dividida en capas para garantizar la separación de responsabilidades:

1.  **Kiosco.Domain**: Contiene las Entidades (`Project`, `User`, etc.) y las Interfaces del repositorio (`IRepository<T>`). No tiene dependencias externas.
2.  **Kiosco.Application**: Contiene la lógica de negocio, DTOs y Servicios (`ProjectService`). Depende de `Domain` pero no de la infraestructura concreta.
3.  **Kiosco.Infrastructure**: Implementa el acceso a datos con MongoDB (`MongoRepository`, `MongoDbContext`).
4.  **Kiosco.API**: El punto de entrada (Controllers) y configuración (`Program.cs`, `appsettings.json`).

## 🚀 Tecnologías

*   **.NET 8**: Framework principal.
*   **MongoDB**: Base de datos NoSQL.
*   **MongoDB.Driver**: Cliente oficial para .NET.
*   **Clean Architecture**: Patrón de diseño.

## ⚙️ Configuración

La conexión a la base de datos se configura en `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "MongoDbConnection": "mongodb+srv://<user>:<password>@cluster0.jvzqseh.mongodb.net/kiosco_db?..."
  }
}
```

## 🔌 Endpoints de la API

### Proyectos (Admin)

Base URL: `/api/admin/projects`

#### 1. Obtener todos los proyectos
*   **Método**: `GET`
*   **URL**: `/api/admin/projects`
*   **Respuesta**: Array JSON de objetos `ProjectDto`.

#### 2. Obtener un proyecto por ID
*   **Método**: `GET`
*   **URL**: `/api/admin/projects/{id}`
*   **Respuesta**: Objeto `ProjectDto` o `404 Not Found`.

#### 3. Crear un proyecto
*   **Método**: `POST`
*   **URL**: `/api/admin/projects`
*   **Body (JSON)**:
    ```json
    {
      "title": "Nuevo Proyecto",
      "description": "Descripción del proyecto",
      "category": "Innovación",
      "teamMembers": ["Juan", "Ana"],
      "coverImageUrl": "https://example.com/image.jpg"
    }
    ```
*   **Validaciones**: El título debe ser único.
*   **Respuesta**: `201 Created` con el objeto creado.

#### 4. Actualizar un proyecto
*   **Método**: `PUT`
*   **URL**: `/api/admin/projects/{id}`
*   **Body (JSON)**: (Campos opcionales)
    ```json
    {
      "title": "Título Actualizado",
      "status": "Inactive"
    }
    ```
*   **Respuesta**: `204 No Content` o `404 Not Found`.

#### 5. Eliminar (Archivar) un proyecto
*   **Método**: `DELETE`
*   **URL**: `/api/admin/projects/{id}`
*   **Lógica**:
    *   Si el proyecto tiene votos (`VoteCount > 0`), **NO** se elimina físicamente, sino que se recomienda cambiar su estado a `Inactive` (Soft Delete). La API retornará un error `400 Bad Request` indicando esto.
    *   Si no tiene votos, se elimina permanentemente.
*   **Respuesta**: `204 No Content` o `400 Bad Request`.

## 📦 Modelos de Datos

### Project (Entidad)
Representa un proyecto en el catálogo.
*   `Id`: ObjectId (String).
*   `Title`: String (Único).
*   `Description`: String.
*   `Category`: String.
*   `TeamMembers`: List<String>.
*   `CoverImageUrl`: String (URL).
*   `Documents`: List<ProjectDocument>.
*   `Status`: "Active" | "Inactive".
*   `Stats`: Objeto con `VoteCount` y `AverageScore`.

---
**Desarrollado por**: Asistente de IA (Google Deepmind)
**Fecha**: 16 de Febrero de 2026
