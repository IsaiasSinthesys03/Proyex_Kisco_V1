using Kiosco.Application.Interfaces;
using Kiosco.Domain.Entities;
using Kiosco.Domain.Interfaces;

namespace Kiosco.Application.Services;

public class TemplateService : ITemplateService
{
    private readonly IRepository<EvaluationTemplate> _repository;
    private readonly IAuditService _auditService;

    public TemplateService(IRepository<EvaluationTemplate> repository, IAuditService auditService)
    {
        _repository = repository;
        _auditService = auditService;
    }

    public async Task<IEnumerable<EvaluationTemplate>> GetAllTemplatesAsync()
    {
        return await _repository.GetAllAsync();
    }

    public async Task<EvaluationTemplate?> GetActiveTemplateAsync()
    {
        var templates = await _repository.GetAsync(t => t.IsActive);
        return templates.FirstOrDefault();
    }

    public async Task<EvaluationTemplate?> GetByIdAsync(string id)
    {
        if (string.IsNullOrWhiteSpace(id)) return null;
        return await _repository.GetByIdAsync(id.Trim());
    }

    public async Task CreateTemplateAsync(EvaluationTemplate template)
    {
        if (template.IsActive)
        {
            await DeactivateOtherTemplatesAsync();
        }
        await _repository.CreateAsync(template);
        await _auditService.LogActionAsync("Crear Plantilla", "Template", template.Id!, $"Plantilla '{template.Version}' creada.");
    }

    public async Task UpdateTemplateAsync(string id, EvaluationTemplate template)
    {
        if (string.IsNullOrWhiteSpace(id)) return;
        
        if (template.IsActive)
        {
            await DeactivateOtherTemplatesAsync(id.Trim());
        }
        await _repository.UpdateAsync(id.Trim(), template);
        await _auditService.LogActionAsync("Actualizar Plantilla", "Template", id.Trim(), $"Plantilla '{template.Version}' actualizada.");
    }

    public async Task DeleteTemplateAsync(string id)
    {
        if (string.IsNullOrWhiteSpace(id)) return;
        var template = await _repository.GetByIdAsync(id.Trim());
        var version = template?.Version ?? "Desconocida";
        
        await _repository.DeleteAsync(id.Trim());
        await _auditService.LogActionAsync("Eliminar Plantilla", "Template", id.Trim(), $"Plantilla '{version}' eliminada.");
    }

    private async Task DeactivateOtherTemplatesAsync(string? excludeId = null)
    {
        var activeTemplates = await _repository.GetAsync(t => t.IsActive);
        foreach (var active in activeTemplates)
        {
            // Comparación segura de IDs
            if (active.Id?.ToString() != excludeId)
            {
                active.IsActive = false;
                await _repository.UpdateAsync(active.Id!, active);
            }
        }
    }
}
