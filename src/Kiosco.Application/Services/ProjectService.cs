using Kiosco.Application.DTOs;
using Kiosco.Application.Interfaces;
using Kiosco.Domain.Entities;
using Kiosco.Domain.Interfaces;
using Kiosco.Domain.Exceptions;

namespace Kiosco.Application.Services;

public class ProjectService : IProjectService
{
    private readonly IRepository<Project> _repository;
    private readonly IAuditService _auditService;

    public ProjectService(IRepository<Project> repository, IAuditService auditService)
    {
        _repository = repository;
        _auditService = auditService;
    }

    public async Task<IEnumerable<ProjectDto>> GetPublicProjectsAsync(string? searchTerm = null, string? category = null)
    {
        var all = await _repository.GetAllAsync();
        var projects = all.Where(p => 
            p.Status == "Active" &&
            (string.IsNullOrEmpty(searchTerm) || 
             p.Title.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) || 
             p.Description.Contains(searchTerm, StringComparison.OrdinalIgnoreCase)) &&
            (string.IsNullOrEmpty(category) || p.Category == category)
        );

        return MapToDtoList(projects);
    }

    private IEnumerable<ProjectDto> MapToDtoList(IEnumerable<Project> projects)
    {
        return projects.Select(p => new ProjectDto
        {
            Id = p.Id,
            Title = p.Title,
            Description = p.Description,
            Category = p.Category,
            TeamMembers = p.TeamMembers,
            CoverImageUrl = p.CoverImageUrl,
            IconUrl = p.IconUrl,
            VideoUrl = p.VideoUrl,
            GalleryUrls = p.GalleryUrls,
            Documents = p.Documents.Select(d => new DocumentDto { Title = d.Title, Url = d.Url, Type = d.Type }).ToList(),
            Objectives = p.Objectives,
            TechStack = p.TechStack,
            Status = p.Status,
            VoteCount = p.Stats.VoteCount
        });
    }

    public async Task<IEnumerable<ProjectDto>> GetAllProjectsAsync(string? searchTerm = null, string? category = null)
    {
        IEnumerable<Project> projects;

        if (string.IsNullOrEmpty(searchTerm) && string.IsNullOrEmpty(category))
        {
            projects = await _repository.GetAllAsync();
        }
        else
        {
            var all = await _repository.GetAllAsync();
            projects = all.Where(p =>
                (string.IsNullOrEmpty(searchTerm) || 
                 p.Title.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) || 
                 p.Description.Contains(searchTerm, StringComparison.OrdinalIgnoreCase)) &&
                (string.IsNullOrEmpty(category) || p.Category == category)
            );
        }

        return MapToDtoList(projects);
    }

    public async Task<ProjectDto?> GetProjectByIdAsync(string id)
    {
        var project = await _repository.GetByIdAsync(id);
        if (project == null) return null;

        return new ProjectDto
        {
            Id = project.Id,
            Title = project.Title,
            Description = project.Description,
            Category = project.Category,
            TeamMembers = project.TeamMembers,
            CoverImageUrl = project.CoverImageUrl,
            IconUrl = project.IconUrl,
            VideoUrl = project.VideoUrl,
            GalleryUrls = project.GalleryUrls,
            Documents = project.Documents.Select(d => new DocumentDto { Title = d.Title, Url = d.Url, Type = d.Type }).ToList(),
            Objectives = project.Objectives,
            TechStack = project.TechStack,
            Status = project.Status,
            VoteCount = project.Stats.VoteCount
        };
    }

    public async Task<ProjectDto> CreateProjectAsync(CreateProjectDto createDto)
    {
        // 1. Validar Título Único
        var existing = await _repository.GetAsync(p => p.Title == createDto.Title);
        if (existing.Any())
        {
            throw new ValidationException($"Ya existe un proyecto con el título '{createDto.Title}'.");
        }

        var project = new Project
        {
            Title = createDto.Title,
            Description = createDto.Description,
            Category = createDto.Category,
            TeamMembers = createDto.TeamMembers,
            CoverImageUrl = createDto.CoverImageUrl,
            IconUrl = createDto.IconUrl,
            VideoUrl = createDto.VideoUrl,
            GalleryUrls = createDto.GalleryUrls,
            Documents = createDto.Documents.Select(d => new ProjectDocument { Title = d.Title, Url = d.Url, Type = d.Type }).ToList(),
            Objectives = createDto.Objectives,
            TechStack = createDto.TechStack,
            Status = "Active",
            CreatedAt = DateTime.UtcNow
        };

        await _repository.CreateAsync(project);

        await _auditService.LogActionAsync("Crear Proyecto", "Project", project.Id, $"Proyecto '{project.Title}' creado.");

        return new ProjectDto
        {
            Id = project.Id,
            Title = project.Title,
            Description = project.Description,
            Category = project.Category,
            TeamMembers = project.TeamMembers,
            CoverImageUrl = project.CoverImageUrl,
            IconUrl = project.IconUrl,
            VideoUrl = project.VideoUrl,
            GalleryUrls = project.GalleryUrls,
            Documents = project.Documents.Select(d => new DocumentDto { Title = d.Title, Url = d.Url, Type = d.Type }).ToList(),
            Objectives = project.Objectives,
            TechStack = project.TechStack,
            Status = project.Status,
            VoteCount = 0
        };
    }

    public async Task UpdateProjectAsync(string id, UpdateProjectDto updateDto)
    {
        var project = await _repository.GetByIdAsync(id);
        if (project == null) throw new ResourceNotFoundException("Proyecto", id);

        var oldTitle = project.Title;
        if (updateDto.Title != null) project.Title = updateDto.Title;
        if (updateDto.Description != null) project.Description = updateDto.Description;
        if (updateDto.Category != null) project.Category = updateDto.Category;
        if (updateDto.TeamMembers != null) project.TeamMembers = updateDto.TeamMembers;
        if (updateDto.CoverImageUrl != null) project.CoverImageUrl = updateDto.CoverImageUrl;
        if (updateDto.IconUrl != null) project.IconUrl = updateDto.IconUrl;
        if (updateDto.VideoUrl != null) project.VideoUrl = updateDto.VideoUrl;
        if (updateDto.GalleryUrls != null) project.GalleryUrls = updateDto.GalleryUrls;
        if (updateDto.Documents != null)
        {
            project.Documents = updateDto.Documents.Select(d => new ProjectDocument
            {
                Title = d.Title,
                Url = d.Url,
                Type = d.Type
            }).ToList();
        }
        if (updateDto.Objectives != null) project.Objectives = updateDto.Objectives;
        if (updateDto.TechStack != null) project.TechStack = updateDto.TechStack;
        if (updateDto.Status != null) project.Status = updateDto.Status;

        project.UpdatedAt = DateTime.UtcNow;

        await _repository.UpdateAsync(id, project);

        await _auditService.LogActionAsync("Actualizar Proyecto", "Project", id, $"Proyecto '{oldTitle}' actualizado.");
    }

    public async Task DeleteProjectAsync(string id)
    {
        var project = await _repository.GetByIdAsync(id);
        if (project == null) throw new ResourceNotFoundException("Proyecto", id);

        // Regla: Si tiene votos, no eliminar, sino archivar (Status = Inactive)
        if (project.Stats.VoteCount > 0)
        {
            throw new BusinessRuleException("No se puede eliminar un proyecto que tiene votos. Por favor, archívelo cambiando su estado a 'Inactivo'.");
        }

        var title = project.Title;
        await _repository.DeleteAsync(id);

        await _auditService.LogActionAsync("Eliminar Proyecto", "Project", id, $"Proyecto '{title}' eliminado.");
    }
}
