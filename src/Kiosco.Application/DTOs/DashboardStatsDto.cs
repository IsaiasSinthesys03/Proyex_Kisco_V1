using System.Collections.Generic;

namespace Kiosco.Application.DTOs;

public class DashboardStatsDto
{
    public int TotalProjects { get; set; }
    public int TotalEvaluations { get; set; }
    public double GlobalAverageScore { get; set; }
    public bool IsVotingEnabled { get; set; }
    
    public List<CategoryDistributionDto> CategoryDistribution { get; set; } = new();
    public List<ProjectRankingDto> TopProjects { get; set; } = new();
    public List<RecentEvaluationDto> RecentEvaluations { get; set; } = new();
}

public class CategoryDistributionDto
{
    public string Category { get; set; } = string.Empty;
    public int Count { get; set; }
}

public class ProjectRankingDto
{
    public string ProjectId { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public double AverageScore { get; set; }
    public int VoteCount { get; set; }
}

public class RecentEvaluationDto
{
    public string ProjectTitle { get; set; } = string.Empty;
    public string Comment { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
}
