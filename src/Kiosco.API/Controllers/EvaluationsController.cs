using Kiosco.Application.DTOs;
using Kiosco.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class EvaluationsController : ControllerBase
{
    private readonly IEvaluationService _evaluationService;
    private readonly ISettingsService _settingsService;

    public EvaluationsController(IEvaluationService evaluationService, ISettingsService settingsService)
    {
        _evaluationService = evaluationService;
        _settingsService = settingsService;
    }

    [HttpPost]
    public async Task<IActionResult> Submit(EvaluationSubmitDto submitDto)
    {
        var settings = await _settingsService.GetSettingsAsync();
        if (settings != null && !settings.IsVotingEnabled)
        {
            return BadRequest("Las votaciones están cerradas actualmente.");
        }

        await _evaluationService.SubmitEvaluationAsync(submitDto);
        return Ok(new { message = "Evaluación recibida correctamente." });
    }

    [HttpGet("ranking")]
    public async Task<IActionResult> GetRanking()
    {
        var settings = await _settingsService.GetSettingsAsync();
        if (settings != null && !settings.IsRankingPublic)
        {
            return Forbid("El ranking aún no es público.");
        }

        var ranking = await _evaluationService.GetRankingAsync();
        return Ok(ranking);
    }
}
