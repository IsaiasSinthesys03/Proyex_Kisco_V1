using Kiosco.Application.Interfaces;
using Kiosco.Domain.Entities;
using Kiosco.Domain.Interfaces;

namespace Kiosco.Application.Services;

public class SettingsService : ISettingsService
{
    private readonly IRepository<GlobalSettings> _repository;
    private readonly IAuditService _auditService;

    public SettingsService(IRepository<GlobalSettings> repository, IAuditService auditService)
    {
        _repository = repository;
        _auditService = auditService;
    }

    public async Task<GlobalSettings?> GetSettingsAsync()
    {
        var settingsList = await _repository.GetAllAsync();
        return settingsList.FirstOrDefault();
    }

    public async Task UpdateSettingsAsync(GlobalSettings settings)
    {
        var existing = await GetSettingsAsync();
        
        if (existing != null)
        {
            // Mantenemos el mismo ID del documento existente
            settings.Id = existing.Id;
            await _repository.UpdateAsync(existing.Id, settings);
            await _auditService.LogActionAsync("Actualizar Ajustes", "Settings", settings.Id, "Configuración global actualizada.");
        }
        else
        {
            await _repository.CreateAsync(settings);
            await _auditService.LogActionAsync("Crear Ajustes", "Settings", settings.Id ?? "new", "Configuración global inicializada.");
        }
    }
}
