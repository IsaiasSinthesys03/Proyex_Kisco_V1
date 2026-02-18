using System.Net;
using System.Text.Json;

namespace Kiosco.API.Middleware;

public class ExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionMiddleware> _logger;
    private readonly IHostEnvironment _env;

    public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger, IHostEnvironment env)
    {
        _next = next;
        _logger = logger;
        _env = env;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error capturado por middleware: {Message}", ex.Message);
            context.Response.ContentType = "application/json";
            
            var (statusCode, errorCode) = ex switch
            {
                Kiosco.Domain.Exceptions.KioscoBaseException kex => ((int)kex.StatusCode, kex.ErrorCode),
                ArgumentException => ((int)HttpStatusCode.BadRequest, "INVALID_ARGUMENT"),
                InvalidOperationException => ((int)HttpStatusCode.BadRequest, "INVALID_OPERATION"),
                KeyNotFoundException => ((int)HttpStatusCode.NotFound, "KEY_NOT_FOUND"),
                UnauthorizedAccessException => ((int)HttpStatusCode.Unauthorized, "UNAUTHORIZED_ACCESS"),
                _ => ((int)HttpStatusCode.InternalServerError, "INTERNAL_SERVER_ERROR")
            };

            context.Response.StatusCode = statusCode;

            var response = new
            {
                StatusCode = statusCode,
                ErrorCode = errorCode,
                Message = ex.Message,
                Detail = _env.IsDevelopment() ? ex.StackTrace?.ToString() : null,
                Timestamp = DateTime.UtcNow
            };

            var options = new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };
            var json = JsonSerializer.Serialize(response, options);

            await context.Response.WriteAsync(json);
        }
    }
}
