using Kiosco.Application.Interfaces;
using Kiosco.Domain.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers;

[ApiController]
[Route("api/admin/[controller]")]
[Authorize(Roles = "SuperAdmin")]
public class AdminTemplatesController : ControllerBase
{
    private readonly ITemplateService _templateService;

    public AdminTemplatesController(ITemplateService templateService)
    {
        _templateService = templateService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var templates = await _templateService.GetAllTemplatesAsync();
        return Ok(templates);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id)
    {
        var template = await _templateService.GetByIdAsync(id);
        if (template == null) return NotFound();
        return Ok(template);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] EvaluationTemplate template)
    {
        if (string.IsNullOrEmpty(template.Version))
            return BadRequest("La versión es obligatoria.");

        if (template.Sections == null || !template.Sections.Any())
            return BadRequest("La plantilla debe tener al menos una sección.");

        await _templateService.CreateTemplateAsync(template);
        return Ok(template);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(string id, [FromBody] EvaluationTemplate template)
    {
        var existing = await _templateService.GetByIdAsync(id);
        if (existing == null) return NotFound();

        // Asegurar que el ID del objeto coincida con la ruta
        template.Id = id;

        await _templateService.UpdateTemplateAsync(id, template);
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        var existing = await _templateService.GetByIdAsync(id);
        if (existing == null) return NotFound();

        await _templateService.DeleteTemplateAsync(id);
        return NoContent();
    }
}
