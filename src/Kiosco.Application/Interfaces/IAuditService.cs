using Kiosco.Domain.Entities;

namespace Kiosco.Application.Interfaces;

public interface IAuditService
{
    Task LogActionAsync(string action, string entityType, string entityId, string details);
    Task<IEnumerable<AuditLog>> GetRecentLogsAsync(int count = 50);
}
