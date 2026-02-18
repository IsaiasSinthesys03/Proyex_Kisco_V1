using Kiosco.Application.DTOs;
using Kiosco.Application.Interfaces;
using Kiosco.Domain.Entities;
using Kiosco.Domain.Interfaces;
using MongoDB.Driver;
using System.Linq;
using System.Threading.Tasks;

namespace Kiosco.Application.Services;

public class DashboardService : IDashboardService
{
    private readonly IRepository<Project> _projectRepo;
    private readonly IRepository<Evaluation> _evaluationRepo;
    private readonly ISettingsService _settingsService;

    public DashboardService(
        IRepository<Project> projectRepo,
        IRepository<Evaluation> evaluationRepo,
        ISettingsService settingsService)
    {
        _projectRepo = projectRepo;
        _evaluationRepo = evaluationRepo;
        _settingsService = settingsService;
    }

    public async Task<DashboardStatsDto> GetStatsAsync()
    {
        var projects = (await _projectRepo.GetAllAsync()).ToList();
        var evaluations = (await _evaluationRepo.GetAllAsync()).ToList();
        var settings = await _settingsService.GetSettingsAsync();

        var stats = new DashboardStatsDto
        {
            TotalProjects = projects.Count,
            TotalEvaluations = evaluations.Count,
            IsVotingEnabled = settings?.IsVotingEnabled ?? false,
            GlobalAverageScore = projects.Any(p => p.Stats.VoteCount > 0) 
                ? projects.Where(p => p.Stats.VoteCount > 0).Average(p => p.Stats.AverageScore) 
                : 0
        };

        // Distribución por Categoría
        stats.CategoryDistribution = projects
            .GroupBy(p => p.Category)
            .Select(g => new CategoryDistributionDto
            {
                Category = g.Key,
                Count = g.Count()
            })
            .OrderByDescending(c => c.Count)
            .ToList();

        // Top 5 Proyectos
        stats.TopProjects = projects
            .OrderByDescending(p => p.Stats.AverageScore)
            .ThenByDescending(p => p.Stats.VoteCount)
            .Take(5)
            .Select(p => new ProjectRankingDto
            {
                ProjectId = p.Id,
                Title = p.Title,
                AverageScore = p.Stats.AverageScore,
                VoteCount = p.Stats.VoteCount
            })
            .ToList();

        // 5 Evaluaciones Recientes
        stats.RecentEvaluations = evaluations
            .OrderByDescending(e => e.ServerTimestamp)
            .Take(5)
            .Select(e => new RecentEvaluationDto
            {
                ProjectTitle = projects.FirstOrDefault(p => p.Id == e.ProjectId)?.Title ?? "Proyecto Desconocido",
                Comment = e.Comment ?? "Sin comentario",
                Timestamp = e.ServerTimestamp
            })
            .ToList();

        return stats;
    }
}
