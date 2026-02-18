using Kiosco.Application.DTOs;

namespace Kiosco.Application.Interfaces;

public interface IProjectService
{
    Task<IEnumerable<ProjectDto>> GetAllProjectsAsync(string? searchTerm = null, string? category = null);
    Task<IEnumerable<ProjectDto>> GetPublicProjectsAsync(string? searchTerm = null, string? category = null);
    Task<ProjectDto?> GetProjectByIdAsync(string id);
    Task<ProjectDto> CreateProjectAsync(CreateProjectDto createDto);
    Task UpdateProjectAsync(string id, UpdateProjectDto updateDto);
    Task DeleteProjectAsync(string id);
}
