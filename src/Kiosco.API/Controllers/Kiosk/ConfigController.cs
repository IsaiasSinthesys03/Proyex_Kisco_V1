using Kiosco.Application.Interfaces;
using Kiosco.API.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers.Kiosk;

[ApiController]
[KioskAuthFilter]
[Route("api/kiosk/[controller]")]
public class ConfigController : ControllerBase
{
    private readonly ISettingsService _settingsService;
    private readonly ITemplateService _templateService;

    public ConfigController(ISettingsService settingsService, ITemplateService templateService)
    {
        _settingsService = settingsService;
        _templateService = templateService;
    }

    [HttpGet("handshake")]
    public async Task<IActionResult> Handshake()
    {
        var settings = await _settingsService.GetSettingsAsync();
        var template = await _templateService.GetActiveTemplateAsync();

        return Ok(new
        {
            eventName = settings?.EventName ?? "Kiosco",
            isVotingEnabled = settings?.IsVotingEnabled ?? false,
            isRankingPublic = settings?.IsRankingPublic ?? false,
            templateVersion = template?.Version ?? "0.0"
        });
    }
}
