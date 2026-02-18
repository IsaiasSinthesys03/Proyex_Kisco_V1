using Kiosco.Application.Interfaces;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;

namespace Kiosco.Infrastructure.Services;

public class LocalFileStorageService : IFileStorageService
{
    private readonly IWebHostEnvironment _env;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public LocalFileStorageService(IWebHostEnvironment env, IHttpContextAccessor httpContextAccessor)
    {
        _env = env;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<string> SaveFileAsync(Stream fileStream, string fileName, string folder)
    {
        var uploadsPath = Path.Combine(_env.WebRootPath, "uploads", folder);
        
        if (!Directory.Exists(uploadsPath))
        {
            Directory.CreateDirectory(uploadsPath);
        }

        var uniqueFileName = $"{Guid.NewGuid()}_{fileName}";
        var filePath = Path.Combine(uploadsPath, uniqueFileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await fileStream.CopyToAsync(stream);
        }

        var request = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = $"{request?.Scheme}://{request?.Host}";
        
        return $"{baseUrl}/uploads/{folder}/{uniqueFileName}";
    }

    public Task DeleteFileAsync(string fileUrl)
    {
        if (string.IsNullOrEmpty(fileUrl)) return Task.CompletedTask;

        try
        {
            var uri = new Uri(fileUrl);
            var relativePath = uri.LocalPath; // /uploads/folder/filename
            var fullPath = Path.Combine(_env.WebRootPath, relativePath.TrimStart('/'));

            if (File.Exists(fullPath))
            {
                File.Delete(fullPath);
            }
        }
        catch { /* Ignorar errores de URL mal formada */ }

        return Task.CompletedTask;
    }

    public Task<IEnumerable<string>> ListFilesAsync(string folder)
    {
        var uploadsPath = Path.Combine(_env.WebRootPath, "uploads", folder);
        if (!Directory.Exists(uploadsPath))
        {
            return Task.FromResult(Enumerable.Empty<string>());
        }

        var files = Directory.GetFiles(uploadsPath);
        var request = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = $"{request?.Scheme}://{request?.Host}";

        var urls = files.Select(f => $"{baseUrl}/uploads/{folder}/{Path.GetFileName(f)}");
        return Task.FromResult(urls);
    }
}
