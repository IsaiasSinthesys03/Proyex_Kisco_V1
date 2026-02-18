using Kiosco.Application.DTOs;
using Kiosco.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProjectsController : ControllerBase
{
    private readonly IProjectService _projectService;

    public ProjectsController(IProjectService projectService)
    {
        _projectService = projectService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProjectDto>>> GetPublic([FromQuery] string? search = null, [FromQuery] string? category = null)
    {
        var projects = await _projectService.GetPublicProjectsAsync(search, category);
        return Ok(projects);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ProjectDto>> GetById(string id)
    {
        var project = await _projectService.GetProjectByIdAsync(id);
        if (project == null || project.Status != "Active") return NotFound();
        return Ok(project);
    }
}
