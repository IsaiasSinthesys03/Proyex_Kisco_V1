using Kiosco.Application.DTOs;
using Kiosco.Application.Interfaces;
using Kiosco.Domain.Entities;
using Kiosco.Domain.Interfaces;
using MongoDB.Driver;

namespace Kiosco.Application.Services;

public class EvaluationService : IEvaluationService
{
    private readonly IRepository<Evaluation> _evaluationRepo;
    private readonly IRepository<Project> _projectRepo;

    public EvaluationService(IRepository<Evaluation> evaluationRepo, IRepository<Project> projectRepo)
    {
        _evaluationRepo = evaluationRepo;
        _projectRepo = projectRepo;
    }

    public async Task SubmitEvaluationAsync(EvaluationSubmitDto submitDto)
    {
        // 0. Validar Proyecto
        var project = await _projectRepo.GetByIdAsync(submitDto.ProjectId);
        if (project == null) throw new KeyNotFoundException($"El proyecto con ID {submitDto.ProjectId} no existe.");

        // 1. Verificación de Voto Existente (Anti-Spam / Edición)
        var existing = await _evaluationRepo.GetAsync(e => 
            e.ProjectId == submitDto.ProjectId && e.DeviceUuid == submitDto.DeviceUuid);
        
        var existingEval = existing.OrderByDescending(e => e.ServerTimestamp).FirstOrDefault();

        if (existingEval != null)
        {
            var diff = DateTime.UtcNow - existingEval.ServerTimestamp;
            if (diff.TotalMinutes < 30)
            {
                // Actualizar voto existente
                existingEval.Answers = submitDto.Answers.Select(a => new Answer 
                { 
                    QuestionId = a.QuestionId, 
                    Value = a.Value 
                }).ToList();
                existingEval.Comment = submitDto.Comment;
                existingEval.TemplateVersion = submitDto.TemplateVersion;
                existingEval.ClientTimestamp = submitDto.ClientTimestamp;
                
                await _evaluationRepo.UpdateAsync(existingEval.Id, existingEval);
                await UpdateProjectStatsAsync(submitDto.ProjectId);
                return;
            }
            else
            {
                throw new InvalidOperationException("Ya has evaluado este proyecto y el tiempo de edición (30 min) ha expirado.");
            }
        }

        // 2. Guardar evaluación nueva
        var evaluation = new Evaluation
        {
            ProjectId = submitDto.ProjectId,
            DeviceUuid = submitDto.DeviceUuid,
            TemplateVersion = submitDto.TemplateVersion,
            Comment = submitDto.Comment,
            ClientTimestamp = submitDto.ClientTimestamp,
            Answers = submitDto.Answers.Select(a => new Answer 
            { 
                QuestionId = a.QuestionId, 
                Value = a.Value 
            }).ToList()
        };

        await _evaluationRepo.CreateAsync(evaluation);

        // 3. Recalcular estadísticas del proyecto
        await UpdateProjectStatsAsync(submitDto.ProjectId);
    }

    public async Task<IEnumerable<object>> GetRankingAsync()
    {
        var projects = await _projectRepo.GetAllAsync();
        return projects
            .OrderByDescending(p => p.Stats.AverageScore)
            .ThenByDescending(p => p.Stats.VoteCount)
            .Select(p => new 
            {
                p.Id,
                p.Title,
                p.Category,
                AverageScore = p.Stats?.AverageScore ?? 0,
                VoteCount = p.Stats?.VoteCount ?? 0
            });
    }

    public async Task<byte[]> GetRankingCsvAsync()
    {
        var projects = await _projectRepo.GetAllAsync();
        var ranking = projects
            .Where(p => p.Status == "Active")
            .OrderByDescending(p => p.Stats.AverageScore);

        var sb = new System.Text.StringBuilder();
        sb.AppendLine("ID,Titulo,Categoria,Promedio,Votos");

        foreach (var p in ranking)
        {
            var title = p.Title.Replace("\"", "\"\"");
            var category = p.Category.Replace("\"", "\"\"");
            
            var line = $"{p.Id},\"{title}\",\"{category}\",{p.Stats.AverageScore:F2},{p.Stats.VoteCount}";
            sb.AppendLine(line);
        }

        return System.Text.Encoding.UTF8.GetBytes(sb.ToString());
    }

    public async Task<object?> GetProjectFeedbackAsync(string projectId)
    {
        var project = await _projectRepo.GetByIdAsync(projectId);
        if (project == null) return null;

        var evaluations = await _evaluationRepo.GetAsync(e => e.ProjectId == projectId);
        var evalList = evaluations.ToList();

        return new
        {
            project.Id,
            project.Title,
            project.Category,
            Stats = project.Stats,
            Comments = evalList
                .Where(e => !string.IsNullOrWhiteSpace(e.Comment))
                .OrderByDescending(e => e.ServerTimestamp)
                .Select(e => new 
                { 
                    e.Comment, 
                    Timestamp = e.ServerTimestamp,
                    AverageScore = e.Answers.Any() ? Math.Round(e.Answers.Average(a => a.Value), 2) : 0
                })
        };
    }

    private async Task UpdateProjectStatsAsync(string projectId)
    {
        var evaluations = await _evaluationRepo.GetAsync(e => e.ProjectId == projectId);
        var evalList = evaluations.ToList();

        if (!evalList.Any()) return;

        var voteCount = evalList.Count;
        
        // Calculamos el promedio de todos los votos (cada voto es el promedio de sus respuestas)
        var averageScore = evalList
            .Select(e => e.Answers.Average(a => a.Value))
            .Average();

        var project = await _projectRepo.GetByIdAsync(projectId);
        if (project != null)
        {
            project.Stats.VoteCount = voteCount;
            project.Stats.AverageScore = Math.Round(averageScore, 2);
            await _projectRepo.UpdateAsync(projectId, project);
        }
    }
}
