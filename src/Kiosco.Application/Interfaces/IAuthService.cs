using Kiosco.Domain.Entities;

namespace Kiosco.Application.Interfaces;

public interface IAuthService
{
    Task<User?> AuthenticateAsync(string email, string password);
    string GenerateJwtToken(User user);
    Task RegisterAsync(User user, string password);
}
