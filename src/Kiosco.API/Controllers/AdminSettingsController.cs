using Kiosco.Application.Interfaces;
using Kiosco.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers;

[ApiController]
[Route("api/admin/[controller]")]
public class AdminSettingsController : ControllerBase
{
    private readonly ISettingsService _settingsService;

    public AdminSettingsController(ISettingsService settingsService)
    {
        _settingsService = settingsService;
    }

    [HttpGet]
    public async Task<IActionResult> GetSettings()
    {
        var settings = await _settingsService.GetSettingsAsync();
        if (settings == null)
        {
            // Si no existe, devolvemos uno vacío
            return Ok(new GlobalSettings 
            { 
                EventName = "Evento por Defecto",
                IsVotingEnabled = false,
                IsRankingPublic = false
            });
        }
        return Ok(settings);
    }

    [HttpPut]
    public async Task<IActionResult> UpdateSettings([FromBody] GlobalSettings settings)
    {
        if (string.IsNullOrEmpty(settings.EventName))
            return BadRequest("El nombre del evento es requerido.");

        await _settingsService.UpdateSettingsAsync(settings);
        return Ok(new { message = "Configuración actualizada correctamente." });
    }
}
