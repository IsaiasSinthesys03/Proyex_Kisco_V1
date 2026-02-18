using Kiosco.Application.DTOs;

namespace Kiosco.Application.Interfaces;

public interface IEvaluationService
{
    Task SubmitEvaluationAsync(EvaluationSubmitDto submitDto);
    Task<IEnumerable<object>> GetRankingAsync();
    Task<byte[]> GetRankingCsvAsync();
    Task<object?> GetProjectFeedbackAsync(string projectId);
}
