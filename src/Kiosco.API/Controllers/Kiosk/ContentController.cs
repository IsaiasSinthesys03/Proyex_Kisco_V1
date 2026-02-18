using Kiosco.Application.Interfaces;
using Kiosco.API.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers.Kiosk;

[ApiController]
[KioskAuthFilter]
[Route("api/kiosk/[controller]")]
public class ContentController : ControllerBase
{
    private readonly IProjectService _projectService;
    private readonly ITemplateService _templateService;

    public ContentController(IProjectService projectService, ITemplateService templateService)
    {
        _projectService = projectService;
        _templateService = templateService;
    }

    [HttpGet("projects")]
    public async Task<IActionResult> GetProjects([FromQuery] string? search = null, [FromQuery] string? category = null)
    {
        var projects = await _projectService.GetPublicProjectsAsync(search, category);
        // Map to light DTO if needed, but ProjectDto is already quite clean
        return Ok(projects);
    }

    [HttpGet("template")]
    [ResponseCache(Duration = 3600)] // Cacheado 1 hora (Req 226)
    public async Task<IActionResult> GetTemplate()
    {
        var template = await _templateService.GetActiveTemplateAsync();
        if (template == null) return NotFound("No hay una plantilla activa.");
        return Ok(template);
    }

    [HttpGet("projects/{id}")]
    public async Task<IActionResult> GetProjectById(string id)
    {
        var project = await _projectService.GetProjectByIdAsync(id);
        if (project == null || project.Status != "Active") return NotFound();
        return Ok(project);
    }
}
