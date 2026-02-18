using System.Collections.Generic;

namespace Kiosco.Application.DTOs;

public class MediaFileDto
{
    public string Url { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public string? OwnerProjectTitle { get; set; }
    public string? OwnerProjectId { get; set; }
    public bool IsOrphan { get; set; }
}
