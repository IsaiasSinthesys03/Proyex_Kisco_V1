using Kiosco.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TemplatesController : ControllerBase
{
    private readonly ITemplateService _templateService;

    public TemplatesController(ITemplateService templateService)
    {
        _templateService = templateService;
    }

    [HttpGet("active")]
    public async Task<IActionResult> GetActiveTemplate()
    {
        var template = await _templateService.GetActiveTemplateAsync();
        if (template == null) return NotFound("No hay una plantilla activa.");
        return Ok(template);
    }
}
