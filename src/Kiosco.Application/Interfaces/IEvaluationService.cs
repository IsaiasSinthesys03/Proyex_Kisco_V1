using Kiosco.Application.DTOs;

namespace Kiosco.Application.Interfaces;

public interface IEvaluationService
{
    Task SubmitEvaluationAsync(EvaluationSubmitDto submitDto);
    Task<IEnumerable<object>> GetRankingAsync(bool activeOnly = false);
    Task<byte[]> GetRankingCsvAsync();
    Task<object?> GetProjectFeedbackAsync(string projectId);
}
