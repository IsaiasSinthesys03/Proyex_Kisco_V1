using Kiosco.Application.DTOs;
using Kiosco.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers;

[ApiController]
[Authorize]
[Route("api/admin/AdminEvaluations")]
public class AdminEvaluationsController : ControllerBase
{
    private readonly IEvaluationService _evaluationService;

    public AdminEvaluationsController(IEvaluationService evaluationService)
    {
        _evaluationService = evaluationService;
    }

    [HttpGet("ranking")]
    public async Task<IActionResult> GetAllEvaluations()
    {
        var ranking = await _evaluationService.GetRankingAsync();
        return Ok(ranking);
    }

    [HttpGet("export")]
    public async Task<IActionResult> ExportRanking()
    {
        var csvBytes = await _evaluationService.GetRankingCsvAsync();
        return File(csvBytes, "text/csv", $"ranking_{DateTime.Now:yyyyMMdd_HHmm}.csv");
    }

    [HttpGet("{projectId}/feedback")]
    public async Task<IActionResult> GetProjectFeedback(string projectId)
    {
        var feedback = await _evaluationService.GetProjectFeedbackAsync(projectId);
        if (feedback == null) return NotFound();
        return Ok(feedback);
    }
}
