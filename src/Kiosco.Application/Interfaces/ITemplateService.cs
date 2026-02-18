using Kiosco.Application.Interfaces;
using Kiosco.Domain.Entities;

namespace Kiosco.Application.Interfaces;

public interface ITemplateService
{
    Task<IEnumerable<EvaluationTemplate>> GetAllTemplatesAsync();
    Task<EvaluationTemplate?> GetActiveTemplateAsync();
    Task<EvaluationTemplate?> GetByIdAsync(string id);
    Task CreateTemplateAsync(EvaluationTemplate template);
    Task UpdateTemplateAsync(string id, EvaluationTemplate template);
    Task DeleteTemplateAsync(string id);
}
