using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Kiosco.Domain.Entities;

public class Evaluation : BaseEntity
{
    [BsonElement("projectId")]
    [BsonRepresentation(BsonType.ObjectId)]
    public required string ProjectId { get; set; }

    [BsonElement("deviceUuid")]
    public required string DeviceUuid { get; set; } // Indexado

    [BsonElement("templateVersion")]
    public required string TemplateVersion { get; set; } // Snapshot de integridad

    [BsonElement("answers")]
    public List<Answer> Answers { get; set; } = new();

    [BsonElement("comment")]
    public string? Comment { get; set; } // Privado

    // Trazabilidad
    [BsonElement("clientTimestamp")]
    public DateTime ClientTimestamp { get; set; } // Hora del dispositivo (Offline)

    [BsonElement("serverTimestamp")]
    public DateTime ServerTimestamp { get; set; } = DateTime.UtcNow;
}

public class Answer
{
    [BsonElement("questionId")]
    public required string QuestionId { get; set; }

    [BsonElement("value")]
    public int Value { get; set; } // 1-5 stars
}
