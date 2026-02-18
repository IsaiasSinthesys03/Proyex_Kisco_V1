using Kiosco.Domain.Entities;
using Kiosco.Infrastructure.Data;
using MongoDB.Driver;

namespace Kiosco.Infrastructure.Data;

public static class DbMigrations
{
    public static async Task ApplyMigrationsAsync(MongoDbContext db)
    {
        // 1. Indice Unico para Titulo de Proyectos
        var projectIndexKeys = Builders<Project>.IndexKeys.Ascending(p => p.Title);
        var projectIndexOptions = new CreateIndexOptions { Unique = true };
        var projectIndexModel = new CreateIndexModel<Project>(projectIndexKeys, projectIndexOptions);
        await db.Projects.Indexes.CreateOneAsync(projectIndexModel);

        // 2. Indice Unico para Email de Usuarios
        var userIndexKeys = Builders<User>.IndexKeys.Ascending(u => u.Email);
        var userIndexOptions = new CreateIndexOptions { Unique = true };
        var userIndexModel = new CreateIndexModel<User>(userIndexKeys, userIndexOptions);
        await db.Users.Indexes.CreateOneAsync(userIndexModel);

        // 3. Índices para Optimización de Consultas (RF-BACK-05)
        await db.Projects.Indexes.CreateOneAsync(new CreateIndexModel<Project>(Builders<Project>.IndexKeys.Ascending(p => p.Category)));
        await db.Projects.Indexes.CreateOneAsync(new CreateIndexModel<Project>(Builders<Project>.IndexKeys.Ascending(p => p.Status)));
        
        // 4. Índice Compuesto para Anti-Spam (ProjectId + DeviceUuid) - Req 168
        var evalIndexKeys = Builders<Evaluation>.IndexKeys
            .Ascending(e => e.ProjectId)
            .Ascending(e => e.DeviceUuid);
        await db.Evaluations.Indexes.CreateOneAsync(new CreateIndexModel<Evaluation>(evalIndexKeys));
        
        Console.WriteLine("✅ Migraciones (Índices) aplicadas correctamente.");
    }
}
