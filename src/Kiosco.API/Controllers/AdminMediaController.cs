using Kiosco.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers;

[ApiController]
[Route("api/admin/[controller]")]
[Authorize(Roles = "SuperAdmin")]
public class AdminMediaController : ControllerBase
{
    private readonly IMediaService _mediaService;

    public AdminMediaController(IMediaService mediaService)
    {
        _mediaService = mediaService;
    }

    [HttpGet("files")]
    public async Task<IActionResult> GetFiles([FromQuery] string folder = "projects")
    {
        var files = await _mediaService.GetSmartMediaAsync(folder);
        return Ok(files);
    }
    
    [HttpPost("cleanup")]
    public async Task<IActionResult> CleanupOrphans()
    {
        var deletedCount = await _mediaService.CleanupOrphansAsync();
        return Ok(new { message = $"Se eliminaron {deletedCount} archivos huérfanos." });
    }
}
