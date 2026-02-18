using Kiosco.Domain.Entities;
using Kiosco.Infrastructure.Data;
using Kiosco.Infrastructure.Services;
using MongoDB.Driver;

namespace Kiosco.Infrastructure.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(MongoDbContext db)
    {
        // 1. Crear Usuario Admin
        var adminEmail = "admin@kiosco.com";
        var existingAdmin = await db.Users.Find(u => u.Email == adminEmail).FirstOrDefaultAsync();

        if (existingAdmin == null)
        {
            var adminUser = new User
            {
                Email = adminEmail,
                PasswordHash = PasswordHasher.HashPassword("admin123"),
                Role = "SuperAdmin"
            };
            await db.Users.InsertOneAsync(adminUser);
            Console.WriteLine("✅ SuperAdmin creado: admin@kiosco.com / admin123");
        }

        // 1.1 Crear Usuarios del Equipo
        var teamMembers = new List<(string Email, string Password)>
        {
            ("isaias@kiosco.com", "isaias2026"),
            ("erick@kiosco.com", "erick2026"),
            ("jonathan@kiosco.com", "jonathan2026"),
            ("lee@kiosco.com", "lee2026")
        };

        foreach (var member in teamMembers)
        {
            var exists = await db.Users.Find(u => u.Email == member.Email).AnyAsync();
            if (!exists)
            {
                await db.Users.InsertOneAsync(new User
                {
                    Email = member.Email,
                    PasswordHash = PasswordHasher.HashPassword(member.Password),
                    Role = "SuperAdmin"
                });
                Console.WriteLine($"✅ Usuario de equipo creado: {member.Email}");
            }
        }

        // 2. Crear Plantilla v1.0
        var templateVersion = "v1.0";
        var existingTemplate = await db.Templates.Find(t => t.Version == templateVersion).FirstOrDefaultAsync();

        if (existingTemplate == null)
        {
            var template = new EvaluationTemplate
            {
                Version = templateVersion,
                IsActive = true,
                Sections = new List<TemplateSection>
                {
                    new TemplateSection
                    {
                        Title = "Propuesta de Valor e Innovación",
                        Order = 1,
                        Questions = new List<Question>
                        {
                            new Question { Id = "q1", Text = "1. ¿El proyecto resuelve una problemática clara?", Type = "scale_1_5" },
                            new Question { Id = "q2", Text = "2. ¿La solución es innovadora o creativa?", Type = "scale_1_5" },
                            new Question { Id = "q3", Text = "3. ¿El proyecto tiene impacto social o comercial?", Type = "scale_1_5" }
                        }
                    },
                    new TemplateSection
                    {
                        Title = "Ejecución Técnica y Diseño",
                        Order = 2,
                        Questions = new List<Question>
                        {
                            new Question { Id = "q4", Text = "4. ¿La interfaz es intuitiva y fácil de usar?", Type = "scale_1_5" },
                            new Question { Id = "q5", Text = "5. ¿El diseño visual es atractivo?", Type = "scale_1_5" },
                            new Question { Id = "q6", Text = "6. ¿El proyecto funciona sin errores (bugs) visibles?", Type = "scale_1_5" },
                            new Question { Id = "q7", Text = "7. ¿La complejidad técnica es adecuada para el nivel?", Type = "scale_1_5" }
                        }
                    },
                    new TemplateSection
                    {
                        Title = "Comunicación y Documentación",
                        Order = 3,
                        Questions = new List<Question>
                        {
                            new Question { Id = "q8", Text = "8. ¿La presentación del equipo fue clara?", Type = "scale_1_5" },
                            new Question { Id = "q9", Text = "9. ¿La documentación mostrada es completa?", Type = "scale_1_5" },
                            new Question { Id = "q10", Text = "10. ¿Recomendarías este proyecto?", Type = "scale_1_5" }
                        }
                    }
                }
            };
            await db.Templates.InsertOneAsync(template);
            Console.WriteLine("✅ Plantilla v1.0 creada con 10 preguntas.");
        }
        else
        {
            Console.WriteLine("ℹ️ Plantilla v1.0 ya existe.");
        }

        // 3. Configuración Global
        var settings = await db.Settings.Find(_ => true).FirstOrDefaultAsync();
        if (settings == null)
        {
            var initialSettings = new GlobalSettings
            {
                EventName = "Feria de Proyectos 2026",
                IsVotingEnabled = false,
                IsRankingPublic = false
            };
            await db.Settings.InsertOneAsync(initialSettings);
            Console.WriteLine("✅ Configuración Global inicializada.");
        }
        else
        {
            Console.WriteLine("ℹ️ Configuración Global ya existe.");
        }
    }
}
