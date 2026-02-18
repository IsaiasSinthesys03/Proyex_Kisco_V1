using Kiosco.Application.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MediaController : ControllerBase
{
    private readonly IFileStorageService _fileStorage;

    public MediaController(IFileStorageService fileStorage)
    {
        _fileStorage = fileStorage;
    }

    [HttpPost("upload-image")]
    public async Task<IActionResult> UploadImage(IFormFile file)
    {
        if (file == null || file.Length == 0) return BadRequest("No image file uploaded.");
        
        using (var stream = file.OpenReadStream())
        {
            var url = await _fileStorage.SaveFileAsync(stream, file.FileName, "projects");
            return Ok(new { url });
        }
    }

    [HttpPost("upload-document")]
    public async Task<IActionResult> UploadDocument(IFormFile file)
    {
        if (file == null || file.Length == 0) return BadRequest("No document file uploaded.");
        
        using (var stream = file.OpenReadStream())
        {
            var url = await _fileStorage.SaveFileAsync(stream, file.FileName, "documents");
            return Ok(new { url });
        }
    }

    [HttpPost("upload-video")]
    public async Task<IActionResult> UploadVideo(IFormFile file)
    {
        if (file == null || file.Length == 0) return BadRequest("No video file uploaded.");
        
        using (var stream = file.OpenReadStream())
        {
            var url = await _fileStorage.SaveFileAsync(stream, file.FileName, "videos");
            return Ok(new { url });
        }
    }

    [HttpPost("upload-audio")]
    public async Task<IActionResult> UploadAudio(IFormFile file)
    {
        if (file == null || file.Length == 0) return BadRequest("No audio file uploaded.");
        
        using (var stream = file.OpenReadStream())
        {
            var url = await _fileStorage.SaveFileAsync(stream, file.FileName, "audio");
            return Ok(new { url });
        }
    }
}
