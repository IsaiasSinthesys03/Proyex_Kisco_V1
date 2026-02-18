using Kiosco.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kiosco.Application.Interfaces;

public interface IMediaService
{
    Task<IEnumerable<MediaFileDto>> GetSmartMediaAsync(string folder);
    Task<int> CleanupOrphansAsync();
}
