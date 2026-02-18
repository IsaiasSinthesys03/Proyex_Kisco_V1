using Kiosco.Application.Interfaces;
using Kiosco.Domain.Entities;
using Kiosco.Domain.Interfaces;
using Microsoft.AspNetCore.Http;

namespace Kiosco.Application.Services;

public class AuditService : IAuditService
{
    private readonly IRepository<AuditLog> _auditRepo;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public AuditService(IRepository<AuditLog> auditRepo, IHttpContextAccessor httpContextAccessor)
    {
        _auditRepo = auditRepo;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task LogActionAsync(string action, string entityType, string entityId, string details)
    {
        var context = _httpContextAccessor.HttpContext;
        var ipAddress = context?.Connection?.RemoteIpAddress?.ToString();
        
        var userId = context?.User?.FindFirst("userId")?.Value ?? "System";
        var userName = context?.User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value 
                        ?? context?.User?.FindFirst("sub")?.Value 
                        ?? "System";

        var log = new AuditLog
        {
            UserId = userId,
            UserName = userName,
            Action = action,
            EntityType = entityType,
            EntityId = entityId,
            Details = details,
            IpAddress = ipAddress,
            CreatedAt = DateTime.UtcNow
        };

        await _auditRepo.CreateAsync(log);
    }

    public async Task<IEnumerable<AuditLog>> GetRecentLogsAsync(int count = 50)
    {
        var logs = await _auditRepo.GetAllAsync();
        return logs.OrderByDescending(l => l.CreatedAt).Take(count);
    }
}
