namespace Kiosco.Application.DTOs;

public class AuthDto
{
    public required string Email { get; set; }
    public required string Password { get; set; }
}

public class RegisterDto : AuthDto
{
    public string Role { get; set; } = "Viewer";
}
