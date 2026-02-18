using Kiosco.Application.Interfaces;
using Kiosco.API.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers.Kiosk;

[ApiController]
[KioskAuthFilter]
[Route("api/kiosk/[controller]")]
public class RankingController : ControllerBase
{
    private readonly IEvaluationService _evaluationService;
    private readonly ISettingsService _settingsService;

    public RankingController(IEvaluationService evaluationService, ISettingsService settingsService)
    {
        _evaluationService = evaluationService;
        _settingsService = settingsService;
    }

    [HttpGet]
    public async Task<IActionResult> GetRanking()
    {
        var settings = await _settingsService.GetSettingsAsync();
        
        // Req 238-239: Verificar si el ranking es público
        if (settings == null || !settings.IsRankingPublic)
        {
            return Ok(new { status = "hidden", message = "El ranking aún no es público." });
        }

        var ranking = await _evaluationService.GetRankingAsync();
        return Ok(ranking);
    }
}
