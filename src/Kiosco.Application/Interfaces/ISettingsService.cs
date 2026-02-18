using Kiosco.Domain.Entities;
using Kiosco.Domain.Interfaces;

namespace Kiosco.Application.Interfaces;

public interface ISettingsService
{
    Task<GlobalSettings?> GetSettingsAsync();
    Task UpdateSettingsAsync(GlobalSettings settings);
}
