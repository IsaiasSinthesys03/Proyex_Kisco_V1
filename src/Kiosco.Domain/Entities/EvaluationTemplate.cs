using MongoDB.Bson.Serialization.Attributes;

namespace Kiosco.Domain.Entities;

public class EvaluationTemplate : BaseEntity
{
    [BsonElement("version")]
    public required string Version { get; set; } // "v1.2"

    [BsonElement("isActive")]
    public bool IsActive { get; set; } // Index

    // Estructura anidada flexible (Ventaja de Mongo)
    [BsonElement("sections")]
    public List<TemplateSection> Sections { get; set; } = new();
}

public class TemplateSection
{
    [BsonElement("title")]
    public required string Title { get; set; }

    [BsonElement("order")]
    public int Order { get; set; }

    [BsonElement("questions")]
    public List<Question> Questions { get; set; } = new();
}

public class Question
{
    [BsonElement("id")]
    public required string Id { get; set; } // "q1"

    [BsonElement("text")]
    public required string Text { get; set; }

    [BsonElement("type")]
    public string Type { get; set; } = "scale_1_5";
}
