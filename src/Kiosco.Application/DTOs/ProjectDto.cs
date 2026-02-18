namespace Kiosco.Application.DTOs;

public class ProjectDto
{
    public string Id { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public List<string> TeamMembers { get; set; } = new();
    public string? CoverImageUrl { get; set; }
    public string? IconUrl { get; set; }
    public string? VideoUrl { get; set; }
    public List<string> GalleryUrls { get; set; } = new();
    public List<DocumentDto> Documents { get; set; } = new();
    public List<string> Objectives { get; set; } = new();
    public List<string> TechStack { get; set; } = new();
    public string? Status { get; set; }
    public int VoteCount { get; set; }
}
