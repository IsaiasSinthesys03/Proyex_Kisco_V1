using Kiosco.Application.DTOs;
using System.Threading.Tasks;

namespace Kiosco.Application.Interfaces;

public interface IDashboardService
{
    Task<DashboardStatsDto> GetStatsAsync();
}
