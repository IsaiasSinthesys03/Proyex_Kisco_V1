using Microsoft.AspNetCore.SignalR;

namespace Kiosco.API.Hubs;

public class RankingHub : Hub
{
    // ReceiveVoteUpdate(string projectId, double newAverage)
    // ReceiveDashboardStats(int totalVotes)
    
    public override async Task OnConnectedAsync()
    {
        await base.OnConnectedAsync();
    }
}
