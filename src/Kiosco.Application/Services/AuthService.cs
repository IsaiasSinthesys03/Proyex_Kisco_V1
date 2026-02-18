using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Kiosco.Application.Interfaces;
using Kiosco.Domain.Entities;
using Kiosco.Domain.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace Kiosco.Application.Services;

public class AuthService : IAuthService
{
    private readonly IRepository<User> _userRepo;
    private readonly IConfiguration _config;

    public AuthService(IRepository<User> userRepo, IConfiguration config)
    {
        _userRepo = userRepo;
        _config = config;
    }

    public async Task<User?> AuthenticateAsync(string email, string password)
    {
        var users = await _userRepo.GetAllAsync();
        var user = users.FirstOrDefault(u => u.Email == email);
        
        if (user == null || !BCrypt.Net.BCrypt.Verify(password, user.PasswordHash))
            return null;

        return user;
    }

    public string GenerateJwtToken(User user)
    {
        var key = _config["Jwt:Key"];
        var issuer = _config["Jwt:Issuer"];
        var audience = _config["Jwt:Audience"];
        var expireMinutes = _config["Jwt:ExpireMinutes"];

        if (string.IsNullOrEmpty(key) || string.IsNullOrEmpty(issuer) || string.IsNullOrEmpty(audience) || string.IsNullOrEmpty(expireMinutes))
            throw new Exception("Falta configuración de JWT en appsettings.json");

        var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
        var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Email),
            new Claim("role", user.Role),
            new Claim("userId", user.Id)
        };

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.Now.AddMinutes(double.Parse(expireMinutes)),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public async Task RegisterAsync(User user, string password)
    {
        // Verificar duplicados (simple)
        var users = await _userRepo.GetAllAsync();
        if (users.Any(u => u.Email == user.Email))
            throw new Exception("El correo electrónico ya está registrado.");

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(password);
        await _userRepo.CreateAsync(user);
    }
}
