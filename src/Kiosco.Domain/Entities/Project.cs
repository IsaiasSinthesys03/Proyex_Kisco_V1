using MongoDB.Bson.Serialization.Attributes;

namespace Kiosco.Domain.Entities;

public class Project : BaseEntity
{
    [BsonElement("title")]
    public required string Title { get; set; }

    [BsonElement("description")]
    public required string Description { get; set; } // HTML Sanitizado

    [BsonElement("teamMembers")]
    public List<string> TeamMembers { get; set; } = new();

    [BsonElement("objectives")]
    public List<string> Objectives { get; set; } = new();

    [BsonElement("techStack")]
    public List<string> TechStack { get; set; } = new();

    [BsonElement("category")]
    public required string Category { get; set; }

    // Multimedia (URLs absolutas)
    [BsonElement("coverImageUrl")]
    public string? CoverImageUrl { get; set; }

    [BsonElement("iconUrl")]
    public string? IconUrl { get; set; }

    [BsonElement("videoUrl")]
    public string? VideoUrl { get; set; } // URL del video demo (YouTube/MP4)

    [BsonElement("galleryUrls")]
    public List<string> GalleryUrls { get; set; } = new();

    // Documentos (Lista de Objetos)
    [BsonElement("documents")]
    public List<ProjectDocument> Documents { get; set; } = new();

    // Estado Lógico (Soft Delete)
    [BsonElement("status")]
    public string Status { get; set; } = "Active"; // "Active", "Inactive"

    // Caché de rendimiento (Se actualiza tras cada voto)
    [BsonElement("stats")]
    public ProjectStats Stats { get; set; } = new();
}

public class ProjectDocument
{
    [BsonElement("title")]
    public required string Title { get; set; }

    [BsonElement("url")]
    public required string Url { get; set; }

    [BsonElement("type")]
    public string Type { get; set; } = "pdf"; // "pdf", "link"
}

public class ProjectStats
{
    [BsonElement("voteCount")]
    public int VoteCount { get; set; }

    [BsonElement("averageScore")]
    public double AverageScore { get; set; }
}
