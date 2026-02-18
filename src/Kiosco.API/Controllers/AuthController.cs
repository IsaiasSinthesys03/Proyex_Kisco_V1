using Kiosco.Application.DTOs;
using Kiosco.Application.Interfaces;
using Kiosco.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Kiosco.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] AuthDto dto)
    {
        var user = await _authService.AuthenticateAsync(dto.Email, dto.Password);
        if (user == null)
            return Unauthorized(new { message = "Credenciales inválidas" });

        var token = _authService.GenerateJwtToken(user);
        return Ok(new { token, user.Email, user.Role, user.Id });
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDto dto)
    {
        try
        {
            var user = new User
            {
                Email = dto.Email,
                Role = string.IsNullOrEmpty(dto.Role) ? "Viewer" : dto.Role,
                PasswordHash = "" // Se generará en el servicio
            };

            await _authService.RegisterAsync(user, dto.Password);
            return Ok(new { message = "Usuario registrado correctamente" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
