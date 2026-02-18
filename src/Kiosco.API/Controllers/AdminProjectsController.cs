using Kiosco.Application.DTOs;
using Kiosco.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers;

[ApiController]
[Authorize]
[Route("api/admin/Projects")]
public class AdminProjectsController : ControllerBase
{
    private readonly IProjectService _projectService;

    public AdminProjectsController(IProjectService projectService)
    {
        _projectService = projectService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProjectDto>>> GetAll([FromQuery] string? search = null, [FromQuery] string? category = null)
    {
        var projects = await _projectService.GetAllProjectsAsync(search, category);
        return Ok(projects);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ProjectDto>> GetById(string id)
    {
        var project = await _projectService.GetProjectByIdAsync(id);
        if (project == null) return NotFound();
        return Ok(project);
    }

    [HttpPost]
    public async Task<ActionResult<ProjectDto>> Create([FromBody] CreateProjectDto createDto)
    {
        Console.WriteLine($"🛠️ DEBUG CREATE: Title={createDto.Title}, IconUrl={createDto.IconUrl}");
        var createdProject = await _projectService.CreateProjectAsync(createDto);
        return CreatedAtAction(nameof(GetById), new { id = createdProject.Id }, createdProject);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(string id, [FromBody] UpdateProjectDto updateDto)
    {
        Console.WriteLine($"🛠️ DEBUG UPDATE: Id={id}, IconUrl={updateDto.IconUrl}");
        await _projectService.UpdateProjectAsync(id, updateDto);
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        await _projectService.DeleteProjectAsync(id);
        return NoContent();
    }
}
