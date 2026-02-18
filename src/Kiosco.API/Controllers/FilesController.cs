using Kiosco.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class FilesController : ControllerBase
{
    private readonly IFileStorageService _fileStorage;
    private readonly IMediaService _mediaService;

    public FilesController(IFileStorageService fileStorage, IMediaService mediaService)
    {
        _fileStorage = fileStorage;
        _mediaService = mediaService;
    }

    [HttpPost("upload")]
    public async Task<IActionResult> Upload([FromForm] List<IFormFile> file, [FromQuery] string folder = "general")
    {
        if (file == null || !file.Any())
        {
            return BadRequest("No se han proporcionado archivos.");
        }

        var results = new List<string>();
        var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".pdf", ".mp4", ".mov", ".doc", ".docx", ".zip" };

        foreach (var f in file)
        {
            if (f.Length > 0)
            {
                var extension = Path.GetExtension(f.FileName).ToLowerInvariant();
                if (!allowedExtensions.Contains(extension)) continue;

                using (var stream = f.OpenReadStream())
                {
                    var fileUrl = await _fileStorage.SaveFileAsync(stream, f.FileName, folder);
                    results.Add(fileUrl);
                }
            }
        }

        return Ok(new { urls = results });
    }

    [HttpGet]
    public async Task<IActionResult> List([FromQuery] string folder = "projects")
    {
        var files = await _mediaService.GetSmartMediaAsync(folder);
        return Ok(files);
    }

    [HttpDelete]
    public async Task<IActionResult> Delete([FromQuery] string url)
    {
        if (string.IsNullOrEmpty(url)) return BadRequest("URL no proporcionada.");
        await _fileStorage.DeleteFileAsync(url);
        return NoContent();
    }
}
