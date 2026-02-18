using Scalar.AspNetCore;
using MongoDB.Driver;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy =>
        {
            policy.SetIsOriginAllowed(origin => true)
                  .AllowAnyMethod()
                  .AllowAnyHeader()
                  .AllowCredentials(); // Required for SignalR
        });
});

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

// Add SignalR for real-time updates
builder.Services.AddSignalR();

// Add Domain Services
builder.Services.AddScoped<Kiosco.Application.Interfaces.IProjectService, Kiosco.Application.Services.ProjectService>();
builder.Services.AddScoped<Kiosco.Application.Interfaces.IEvaluationService, Kiosco.Application.Services.EvaluationService>();
builder.Services.AddScoped<Kiosco.Application.Interfaces.ITemplateService, Kiosco.Application.Services.TemplateService>();
builder.Services.AddScoped<Kiosco.Application.Interfaces.ISettingsService, Kiosco.Application.Services.SettingsService>();
builder.Services.AddScoped<Kiosco.Application.Interfaces.IDashboardService, Kiosco.Application.Services.DashboardService>();
builder.Services.AddScoped<Kiosco.Application.Interfaces.IMediaService, Kiosco.Application.Services.MediaService>();
builder.Services.AddScoped<Kiosco.Application.Interfaces.IAuditService, Kiosco.Application.Services.AuditService>(); // Added AuditService
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<Kiosco.Application.Interfaces.IFileStorageService, Kiosco.Infrastructure.Services.LocalFileStorageService>();

// Add Infrastructure
builder.Services.AddSingleton<Kiosco.Infrastructure.Data.MongoDbContext>();
builder.Services.AddScoped<Kiosco.Domain.Interfaces.IRepository<Kiosco.Domain.Entities.Project>>(sp =>
    new Kiosco.Infrastructure.Repositories.MongoRepository<Kiosco.Domain.Entities.Project>(
        sp.GetRequiredService<Kiosco.Infrastructure.Data.MongoDbContext>().Projects));

builder.Services.AddScoped<Kiosco.Domain.Interfaces.IRepository<Kiosco.Domain.Entities.Evaluation>>(sp =>
    new Kiosco.Infrastructure.Repositories.MongoRepository<Kiosco.Domain.Entities.Evaluation>(
        sp.GetRequiredService<Kiosco.Infrastructure.Data.MongoDbContext>().Evaluations));

builder.Services.AddScoped<Kiosco.Domain.Interfaces.IRepository<Kiosco.Domain.Entities.EvaluationTemplate>>(sp =>
    new Kiosco.Infrastructure.Repositories.MongoRepository<Kiosco.Domain.Entities.EvaluationTemplate>(
        sp.GetRequiredService<Kiosco.Infrastructure.Data.MongoDbContext>().Templates));

builder.Services.AddScoped<Kiosco.Domain.Interfaces.IRepository<Kiosco.Domain.Entities.GlobalSettings>>(sp =>
    new Kiosco.Infrastructure.Repositories.MongoRepository<Kiosco.Domain.Entities.GlobalSettings>(
        sp.GetRequiredService<Kiosco.Infrastructure.Data.MongoDbContext>().Settings));

builder.Services.AddScoped<Kiosco.Domain.Interfaces.IRepository<Kiosco.Domain.Entities.AuditLog>>(sp =>
    new Kiosco.Infrastructure.Repositories.MongoRepository<Kiosco.Domain.Entities.AuditLog>(
        sp.GetRequiredService<Kiosco.Infrastructure.Data.MongoDbContext>().AuditLogs));

// Auth Services
builder.Services.AddScoped<Kiosco.Application.Interfaces.IAuthService, Kiosco.Application.Services.AuthService>();

builder.Services.AddScoped<Kiosco.Domain.Interfaces.IRepository<Kiosco.Domain.Entities.User>>(sp =>
    new Kiosco.Infrastructure.Repositories.MongoRepository<Kiosco.Domain.Entities.User>(
        sp.GetRequiredService<Kiosco.Infrastructure.Data.MongoDbContext>().Users));

// JWT Authentication
builder.Services.AddAuthentication(Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new Microsoft.IdentityModel.Tokens.TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new Microsoft.IdentityModel.Tokens.SymmetricSecurityKey(
                System.Text.Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"] ?? "SECRET_KEY_MISSING"))
        };
    });

var app = builder.Build();

// Run Database Seeder and Migrations
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<Kiosco.Infrastructure.Data.MongoDbContext>();
        await Kiosco.Infrastructure.Data.DbMigrations.ApplyMigrationsAsync(context);
        await Kiosco.Infrastructure.Data.DbSeeder.SeedAsync(context);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while seeding or migrating the database.");
    }
}

// Configure the HTTP request pipeline.
app.UseMiddleware<Kiosco.API.Middleware.ExceptionMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference(); // Default route: /scalar/v1
}

app.UseCors("AllowAll");

// app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<Kiosco.API.Hubs.RankingHub>("/hubs/ranking");

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

// Health Check
app.MapGet("/health", (Kiosco.Infrastructure.Data.MongoDbContext db) =>
{
    try
    {
        // Intenta obtener la lista de colecciones para verificar conexión
        var collections = db.Database.ListCollectionNames().ToList();
        return Results.Ok(new 
        { 
            Status = "Online", 
            Database = db.Database.DatabaseNamespace.DatabaseName, 
            Collections = collections 
        });
    }
    catch (Exception ex)
    {
        return Results.Problem(detail: ex.Message, title: "Database Connection Failed", statusCode: 500);
    }
})
.WithName("HealthCheck");

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
