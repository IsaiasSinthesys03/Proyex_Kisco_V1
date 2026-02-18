using Kiosco.Domain.Entities;
using MongoDB.Driver;
using Microsoft.Extensions.Configuration;

namespace Kiosco.Infrastructure.Data;

public class MongoDbContext
{
    private readonly IMongoDatabase _database;

    public MongoDbContext(IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("MongoDbConnection");
        var mongoClient = new MongoClient(connectionString);
        var databaseName = MongoUrl.Create(connectionString).DatabaseName;
        _database = mongoClient.GetDatabase(databaseName);
    }

    public IMongoDatabase Database => _database;

    public IMongoCollection<User> Users => _database.GetCollection<User>("users");
    public IMongoCollection<Project> Projects => _database.GetCollection<Project>("projects");
    public IMongoCollection<EvaluationTemplate> Templates => _database.GetCollection<EvaluationTemplate>("templates");
    public IMongoCollection<Evaluation> Evaluations => _database.GetCollection<Evaluation>("evaluations");
    public IMongoCollection<GlobalSettings> Settings => _database.GetCollection<GlobalSettings>("settings");
    public IMongoCollection<AuditLog> AuditLogs => _database.GetCollection<AuditLog>("audit_logs");
}
