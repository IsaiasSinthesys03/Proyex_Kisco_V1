using MongoDB.Bson.Serialization.Attributes;

namespace Kiosco.Domain.Entities;

public class GlobalSettings : BaseEntity
{
    [BsonElement("eventName")]
    public required string EventName { get; set; }

    [BsonElement("isVotingEnabled")]
    public bool IsVotingEnabled { get; set; } // Control Entrada

    [BsonElement("isRankingPublic")]
    public bool IsRankingPublic { get; set; } // Control Salida
}
