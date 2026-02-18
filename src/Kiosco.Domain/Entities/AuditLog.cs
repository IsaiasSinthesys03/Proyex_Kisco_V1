using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Kiosco.Domain.Entities;

public class AuditLog : BaseEntity
{
    [BsonElement("userId")]
    public string UserId { get; set; } = string.Empty;

    [BsonElement("userName")]
    public string UserName { get; set; } = string.Empty;

    [BsonElement("action")]
    public string Action { get; set; } = string.Empty; // e.g., "Create Project", "Update Template"

    [BsonElement("entityType")]
    public string EntityType { get; set; } = string.Empty; // e.g., "Project", "EvaluationTemplate"

    [BsonElement("entityId")]
    public string EntityId { get; set; } = string.Empty;

    [BsonElement("details")]
    public string Details { get; set; } = string.Empty; // JSON or human-readable description

    [BsonElement("ipAddress")]
    public string? IpAddress { get; set; }
}
