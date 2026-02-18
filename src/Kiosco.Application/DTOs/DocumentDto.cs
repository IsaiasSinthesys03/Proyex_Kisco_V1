namespace Kiosco.Application.DTOs;

public class DocumentDto
{
    public string Title { get; set; } = string.Empty;
    public string Url { get; set; } = string.Empty;
    public string Type { get; set; } = "pdf"; // "pdf", "link"
}
