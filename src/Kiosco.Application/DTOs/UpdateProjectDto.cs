using System.ComponentModel.DataAnnotations;

namespace Kiosco.Application.DTOs;

public class UpdateProjectDto
{
    [StringLength(100, MinimumLength = 3, ErrorMessage = "El título debe tener entre 3 y 100 caracteres.")]
    public string? Title { get; set; }

    [MinLength(10, ErrorMessage = "La descripción debe tener al menos 10 caracteres.")]
    public string? Description { get; set; }

    public string? Category { get; set; }
    public List<string>? TeamMembers { get; set; }
    public string? CoverImageUrl { get; set; }
    public string? IconUrl { get; set; }
    public string? VideoUrl { get; set; }
    public List<string>? GalleryUrls { get; set; }
    public List<DocumentDto>? Documents { get; set; }
    public List<string>? Objectives { get; set; }
    public List<string>? TechStack { get; set; }
    public string? Status { get; set; }
}
