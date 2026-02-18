# **Especificación Técnica del Backend: ASP.NET Core Web API** 
**Proyecto:** Kiosco de Evaluación (Backend) 

**Versión:** 3.4 (Final Detallada - C# + MongoDB + SignalR) **Fecha:** 10 de Febrero de 2026 

**Tecnología:** .NET 8, MongoDB.Driver, SignalR **Arquitectura:** Clean Architecture (Domain-Driven Design) 
1. ## **Arquitectura de la Solución (Estructura de Carpetas)** 
Para garantizar escalabilidad y mantenimiento, el código debe seguir esta estructura estricta en Visual Studio: 

src/ 

├── Kiosco.Domain/                  # (Capa Núcleo - Sin dependencias externas) 

│   ├── Entities/                   # Modelos de Datos (Mapeados a MongoDB con atributos Bson) │   ├── Enums/                      # Estatus, Roles (SuperAdmin, Staff), Tipos 

│   └── Interfaces/                 # Contratos (IRepository, IService, IUnitOfWork) 

│ 

├── Kiosco.Application/             # (Capa de Lógica de Negocio) 

│   ├── DTOs/                       # Objetos de Transferencia (Request/Response limpios) 

│   ├── Services/                   # Implementación de reglas (VotingService, ProjectService) 

│   ├── Mappers/                    # AutoMapper Profiles (Entity <-> DTO) 

│   └── Validators/                 # FluentValidation Rules (Validaciones complejas) 

│ 

├── Kiosco.Infrastructure/          # (Capa de Acceso a Datos y Externos) 

│   ├── Data/                       # MongoDbContext (Configuración del Driver y Colecciones) 

│   ├── Repositories/               # Implementación de CRUDS (MongoRepository genérico) 

│   └── Services/                   # FileStorageService (Subida de archivos local/cloud), EmailService 

│ 

└── Kiosco.API/                     # (Capa de Entrada - Web API) 

`    `├── Controllers/                # Endpoints (Admin & Mobile) 

`    `├── Hubs/                       # SignalR Hubs (Ranking en Tiempo Real) 

`    `├── Middlewares/                # ErrorHandler, KioskAuth, RateLimiting 

`    `├── Filters/                    # Filtros de Acción y Excepción 

`    `└── Program.cs                  # Inyección de Dependencias y Configuración 
2. ## **Estrategia de Seguridad, Logs y Manejo de Errores** 
1. ### **Autenticación y Autorización** 
- **Web Dashboard (JWT Bearer):** 
  - **Librería:** Microsoft.AspNetCore.Authentication.JwtBearer. 
  - **Access Token:** Expira en 15 min. Contiene Claims: Id, Email, Role. 
  - **Refresh Token:** Expira en 7 días (Almacenado en BD con hash). 
  - **Logout:** Implementar "Lista Negra" o borrado de Refresh Token en BD para revocar acceso. 
- **App Móvil (Kiosk Auth):** 
- **Filtro Personalizado:** [KioskAuthFilter]. 
- **Validación:** 
1. Header X-Device-UUID presente y formato GUID válido. 
1. **Rate Limiting:** Usar AspNetCoreRateLimit para restringir a 100 peticiones / 10 min por IP. 
2. ### **Observabilidad (Logs)** 
- **Librería:** Serilog (Sinks: Console, File rotativo diario). 
- **Formato:** JSON estructurado. 
- **Regla:** Todo error 500 debe registrarse con Log.Error(ex, "Mensaje") incluyendo StackTrace, Endpoint y UUID. 
3. ### **Manejo de Errores Global** 
Implementar un Middleware personalizado ExceptionHandlingMiddleware que intercepte todas las excepciones y devuelva un ProblemDetails estándar (RFC 7807): 

{ 

`  `"type": "[https://kiosco.api/errors/validation](https://kiosco.api/errors/validation)",   "title": "Error de Validación", 

`  `"status": 400, 

`  `"detail": "El campo 'Title' es obligatorio.", 

`  `"instance": "/api/v1/projects" 

} 
3. ## **Modelo de Datos (C# Mapped to MongoDB)** 
Usaremos el Driver Nativo de MongoDB. Las clases deben decorarse con atributos BSON. 
1. ### **Entidad: User (Admin)** 
public class User : BaseEntity { 

`    `public string Email { get; set; } // Index Unique 

`    `public string PasswordHash { get; set; } // BCrypt     public string Role { get; set; } = "SuperAdmin"; 

`    `public string? RefreshToken { get; set; } 

} 
2. ### **Entidad: Project (Catálogo)** 
public class Project : BaseEntity { 

`    `public string Title { get; set; } 

`    `public string Description { get; set; } // HTML Sanitizado     public List<string> TeamMembers { get; set; } 

`    `public string Category { get; set; } 

// Multimedia (URLs absolutas) 

public string CoverImageUrl { get; set; } public string IconUrl { get; set; } 

// Documentos (Lista de Objetos) 

public List<ProjectDocument> Documents { get; set; } 

// Estado Lógico (Soft Delete) 

public string Status { get; set; } = "Active"; // "Active", "Inactive" 

`    `// Caché de rendimiento (Se actualiza tras cada voto)     public ProjectStats Stats { get; set; } 

} 

public class ProjectDocument { 

`    `public string Title { get; set; } 

`    `public string Url { get; set; } 

`    `public string Type { get; set; } // "pdf", "link" } 
3. ### **Entidad: EvaluationTemplate (Encuesta Dinámica)** 
public class EvaluationTemplate : BaseEntity {     public string Version { get; set; } // "v1.2" 

`    `public bool IsActive { get; set; } // Index 

// Estructura anidada flexible (Ventaja de Mongo) 

`    `public List<TemplateSection> Sections { get; set; } } 

public class TemplateSection { 

`    `public string Title { get; set; } 

`    `public int Order { get; set; } 

`    `public List<Question> Questions { get; set; } } 

public class Question { 

`    `public string Id { get; set; } // "q1" 

`    `public string Text { get; set; } 

`    `public string Type { get; set; } = "scale\_1\_5"; } 
4. ### **Entidad: Evaluation (Voto)** 
public class Evaluation : BaseEntity { 

`    `[BsonRepresentation(BsonType.ObjectId)]     public string ProjectId { get; set; } 

public string DeviceUuid { get; set; } // Indexado 

public string TemplateVersion { get; set; } // Snapshot de integridad 

public List<Answer> Answers { get; set; } public string? Comment { get; set; } // Privado 

`    `// Trazabilidad 

`    `public DateTime ClientTimestamp { get; set; } // Hora del dispositivo (Offline)     public DateTime ServerTimestamp { get; set; } = DateTime.UtcNow; 

} 

// Configurar Índice Único Compuesto: { ProjectId: 1, DeviceUuid: 1 } 
5. ### **Entidad: GlobalSettings (Singleton)** 
public class GlobalSettings : BaseEntity { 

`    `public string EventName { get; set; } 

`    `public bool IsVotingEnabled { get; set; } // Control Entrada     public bool IsRankingPublic { get; set; } // Control Salida 

} 
4. ## **Definición Detallada de Endpoints (Controllers)** 
### **Módulo A: Web Dashboard (Privado)** 
**Namespace:** Kiosco.API.Controllers.Admin **Decorador:** [Authorize(Roles = "SuperAdmin")] 
1. #### **Autenticación (AuthController)** 
- **POST** /api/auth/login: 
  - Recibe { email, password }. Valida hash. Genera JWT y Refresh Token. 
- **POST** /api/auth/refresh: 
  - Recibe { refreshToken }. Valida en BD. Genera nuevo Access Token. 
- **POST** /api/auth/logout: 
- Recibe { refreshToken }. Busca usuario y setea RefreshToken = null. 
2. #### **Gestión de Archivos (UploadController)** 
- **POST** /api/admin/upload: 
- **Input:** IFormFile file. 
- **Validación:** Extensión permitida (.jpg, .png, .pdf), tamaño < 10MB. 
- **Acción:** Guardar en disco (wwwroot) o S3. 
- **Output:** URL pública del recurso. 
3. #### **Gestión de Proyectos (ProjectsController)** 
- **GET** /api/admin/projects: 
- **Query:** page, limit, search, status (opcional). 
- **Output:** PagedResult<ProjectDto>. 
- **POST** /api/admin/projects: 
- **Validación:** Título único, campos requeridos no vacíos. 
- **Sanitización:** Usar HtmlSanitizer para limpiar la Descripción. 
- **PUT** /api/admin/projects/{id}: 
- **Acción:** Actualizar campos. Permite cambiar Status a "Inactive" (Soft Delete). 
- **DELETE** /api/admin/projects/{id}: 
- **Validación de Integridad:** Consultar Stats.VoteCount. 
- **Regla:** Si VoteCount > 0, retornar **400 Bad Request** ("No se puede eliminar un proyecto con votos históricos. Use Archivar."). 
4. #### **Gestión de Encuestas (TemplateController)** 
- **GET** /api/admin/template: Retorna la plantilla con IsActive = true. 
- **POST** /api/admin/template: 
- **Input:** JSON completo de la nueva estructura. 
- **Lógica:** 
1. Verificar si existen evaluaciones en el sistema (Evaluations.CountDocuments()). 
2. Si Count > 0: **Bloquear cambios estructurales**. Comparar JSON nuevo vs viejo. Si hay IDs de preguntas diferentes, rechazar (409 Conflict). 
2. Si Count == 0 o solo cambio de texto: Guardar nueva versión, desactivar anterior. 
#### **5. Analítica y Reportes (StatsController)** 
- **GET** /api/admin/reports/project/{id}: 
- **Output:** JSON complejo con: Info Proyecto, Promedio Final, Desglose por Sección, Lista de Comentarios (Texto plano). 
### **Módulo B: App Móvil (Kiosco)** 
**Namespace:** Kiosco.API.Controllers.Kiosk **Decorador:** [KioskAuthFilter] 
1. #### **Configuración (ConfigController)** 
- **GET** /api/kiosk/handshake: 
- **Output:** { EventName, IsVotingEnabled, IsRankingPublic, TemplateVersion }. 
- **Nota:** La App usa TemplateVersion para validar la integridad de sus borradores locales. 
2. #### **Contenido (ContentController)** 
- **GET** /api/kiosk/projects: 
- **Filtro:** Solo Status == "Active". 
- **Output:** Array ligero ProjectSummaryDto (Id, Titulo, Imagen, Categoria). 
- **GET** /api/kiosk/template: JSON de la encuesta activa (Cacheado 1 hora). 
3. #### **Motor de Evaluación (EvaluationController)** 
- **POST** /api/kiosk/evaluate: 
- **Input:** EvaluationSubmissionDto. 
- **Lógica de Negocio (Service):** 
1. **Validar Estado:** Si IsVotingEnabled == false, retornar 403. 
1. **Validar Integridad:** Iterar Answers. Verificar que cada QuestionId exista en la Template activa. 
1. **Upsert (Crear o Actualizar):** Buscar evaluación existente por (ProjectId, DeviceUuid). 
- **Si existe:** Verificar (DateTime.UtcNow - Existing.ClientTimestamp).TotalMinutes < 30. Si es mayor, retornar 403. Si es menor, ReplaceOne. 
- **Si no existe:** InsertOne. 
4. **Cálculo Asíncrono:** Disparar re-cálculo de promedio y evento SignalR. 
4. #### **Ranking (RankingController)** 
- **GET** /api/kiosk/ranking: 
- **Lógica:** Si IsRankingPublic == false, retornar { status: "hidden" }. Si es true, retornar top proyectos. 
5. ## **Comunicación en Tiempo Real (SignalR)** 
Para cumplir con el requerimiento de "Ranking en Vivo" en el Web Dashboard. 
1. ### **Hub: RankingHub** 
- **Ruta:** /hubs/ranking 
- **Métodos Cliente:** 
- ReceiveVoteUpdate(string projectId, double newAverage): Se dispara tras cada POST /evaluate. 
- ReceiveDashboardStats(int totalVotes): Actualiza contadores globales. 
2. ### **Integración** 
El EvaluationService debe inyectar IHubContext<RankingHub> para emitir eventos después de guardar en MongoDB. 
6. ## **Script de Inicialización (DbSeeder)** 
En .NET, se ejecuta en Program.cs antes del app.Run(). 

public static async Task SeedAsync(IMongoDatabase db) { 

`    `// 1. Crear Índices Únicos (Email, ProjectId+DeviceUuid) 

`    `// 2. Insertar SuperAdmin si no existe 

`    `// 3. Insertar Plantilla v1.0 (10 preguntas estándar) si colección vacía     // 4. Insertar GlobalSettings inicial 

} 
7. ## **Checklist para Desarrollador .NET** 
1. [ ] **NuGet:** Instalar MongoDB.Driver, FluentValidation, AutoMapper, Serilog, BCrypt.Net. 
1. **Configuración:** Mapear CamelCaseElementNameConvention globalmente para que C# PascalCase se guarde como camelCase en Mongo. 
1. **Timezones:** IMPORTANTE. Al recibir ClientTimestamp de la App, asegurarse de que venga en UTC (ISO 8601) y guardarlo así. 
1. **CORS:** Habilitar política CORS permisiva para el Dashboard (Credenciales permitidas para SignalR). 
