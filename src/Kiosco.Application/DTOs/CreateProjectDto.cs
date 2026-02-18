using System.ComponentModel.DataAnnotations;

namespace Kiosco.Application.DTOs;

public class CreateProjectDto
{
    [Required(ErrorMessage = "El título es obligatorio.")]
    [StringLength(100, MinimumLength = 3, ErrorMessage = "El título debe tener entre 3 y 100 caracteres.")]
    public string Title { get; set; } = string.Empty;

    [Required(ErrorMessage = "La descripción es obligatoria.")]
    [MinLength(10, ErrorMessage = "La descripción debe tener al menos 10 caracteres.")]
    public string Description { get; set; } = string.Empty;

    [Required(ErrorMessage = "La categoría es obligatoria.")]
    public string Category { get; set; } = string.Empty;

    public List<string> TeamMembers { get; set; } = new();

    public string? CoverImageUrl { get; set; }
    public string? IconUrl { get; set; }
    public string? VideoUrl { get; set; }
    public List<string> GalleryUrls { get; set; } = new();
    public List<DocumentDto> Documents { get; set; } = new();

    public List<string> Objectives { get; set; } = new();
    public List<string> TechStack { get; set; } = new();
}
