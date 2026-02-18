using Kiosco.Application.DTOs;
using Kiosco.Application.Interfaces;
using Kiosco.Domain.Entities;
using Kiosco.Domain.Interfaces;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Kiosco.Application.Services;

public class MediaService : IMediaService
{
    private readonly IFileStorageService _fileStorage;
    private readonly IRepository<Project> _projectRepo;
    private readonly IAuditService _auditService;

    public MediaService(IFileStorageService fileStorage, IRepository<Project> projectRepo, IAuditService auditService)
    {
        _fileStorage = fileStorage;
        _projectRepo = projectRepo;
        _auditService = auditService;
    }

    public async Task<IEnumerable<MediaFileDto>> GetSmartMediaAsync(string folder)
    {
        var files = (await _fileStorage.ListFilesAsync(folder)).ToList();
        var projects = (await _projectRepo.GetAllAsync()).ToList();

        var result = new List<MediaFileDto>();

        foreach (var fileUrl in files)
        {
            var owner = projects.FirstOrDefault(p => 
                p.CoverImageUrl == fileUrl || 
                p.VideoUrl == fileUrl || 
                p.IconUrl == fileUrl);

            result.Add(new MediaFileDto
            {
                Url = fileUrl,
                FileName = fileUrl.Split('/').Last(),
                OwnerProjectTitle = owner?.Title,
                OwnerProjectId = owner?.Id,
                IsOrphan = owner == null
            });
        }

        return result;
    }

    public async Task<int> CleanupOrphansAsync()
    {
        var files = await GetSmartMediaAsync("projects");
        var orphans = files.Where(f => f.IsOrphan).ToList();
        int deletedCount = 0;

        foreach (var orphan in orphans)
        {
            try
            {
                // DeleteFileAsync espera URL completa
                await _fileStorage.DeleteFileAsync(orphan.Url);
                deletedCount++;
            }
            catch
            {
                // Loggear error si fuera necesario
            }
        }

        if (deletedCount > 0)
        {
            await _auditService.LogActionAsync("Limpiar Multimedia", "Media", "various", $"Se eliminaron {deletedCount} archivos huérfanos.");
        }

        return deletedCount;
    }
}
