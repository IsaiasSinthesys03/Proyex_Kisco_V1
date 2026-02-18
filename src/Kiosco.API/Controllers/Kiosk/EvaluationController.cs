using Kiosco.Application.DTOs;
using Kiosco.Application.Interfaces;
using Kiosco.API.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers.Kiosk;

[ApiController]
[KioskAuthFilter]
[Route("api/kiosk/[controller]")]
public class EvaluationController : ControllerBase
{
    private readonly IEvaluationService _evaluationService;
    private readonly ISettingsService _settingsService;

    public EvaluationController(IEvaluationService evaluationService, ISettingsService settingsService)
    {
        _evaluationService = evaluationService;
        _settingsService = settingsService;
    }

    [HttpPost("evaluate")]
    public async Task<IActionResult> Evaluate(EvaluationSubmitDto submitDto)
    {
        var settings = await _settingsService.GetSettingsAsync();
        if (settings != null && !settings.IsVotingEnabled)
        {
            return Forbid("Las votaciones están cerradas actualmente."); // 403 (Req 231)
        }

        // El UUID del header debe coincidir con el del body por seguridad
        var headerUuid = Request.Headers["X-Device-UUID"].ToString();
        submitDto.DeviceUuid = headerUuid;

        await _evaluationService.SubmitEvaluationAsync(submitDto);
        return Ok(new { message = "Evaluación recibida correctamente." });
    }
}
