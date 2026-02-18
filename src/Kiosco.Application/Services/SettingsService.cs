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
        var settingsList = await _repository.GetAllAsync();
        
        if (settingsList.Any())
        {
            // Limpieza: Si por algún motivo hay más de uno, dejamos solo el primero
            var existing = settingsList.First();
            settings.Id = existing.Id;
            await _repository.UpdateAsync(existing.Id, settings);
            
            // Eliminar duplicados si existen (Resiliencia)
            if (settingsList.Count() > 1)
            {
                foreach (var s in settingsList.Skip(1))
                {
                    if (s.Id != null) await _repository.DeleteAsync(s.Id);
                }
            }

            await _auditService.LogActionAsync("Actualizar Ajustes", "Settings", settings.Id, "Configuración global actualizada.");
        }
        else
        {
            await _repository.CreateAsync(settings);
            await _auditService.LogActionAsync("Crear Ajustes", "Settings", settings.Id ?? "new", "Configuración global inicializada.");
        }
    }
}
