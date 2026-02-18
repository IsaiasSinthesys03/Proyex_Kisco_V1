using System.ComponentModel.DataAnnotations;

namespace Kiosco.Application.DTOs;

public class EvaluationSubmitDto
{
    [Required]
    public string ProjectId { get; set; } = string.Empty;

    [Required]
    public string DeviceUuid { get; set; } = string.Empty;

    [Required]
    public string TemplateVersion { get; set; } = string.Empty;

    [Required]
    public List<AnswerSubmitDto> Answers { get; set; } = new();

    public string? Comment { get; set; }

    public string? Signature { get; set; }

    public DateTime ClientTimestamp { get; set; }
}

public class AnswerSubmitDto
{
    [Required]
    public string QuestionId { get; set; } = string.Empty;

    [Range(1, 5)]
    public int Value { get; set; }
}
