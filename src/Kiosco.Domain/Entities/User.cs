using MongoDB.Bson.Serialization.Attributes;

namespace Kiosco.Domain.Entities;

public class User : BaseEntity
{
    [BsonElement("email")]
    public required string Email { get; set; }

    [BsonElement("passwordHash")]
    public required string PasswordHash { get; set; }

    [BsonElement("role")]
    public string Role { get; set; } = "SuperAdmin";

    [BsonElement("refreshToken")]
    public string? RefreshToken { get; set; }
}
