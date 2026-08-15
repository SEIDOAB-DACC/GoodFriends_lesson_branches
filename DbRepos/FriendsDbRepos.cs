using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using System.Data;

using Models;
using Models.DTO;
using DbModels;
using DbContext;

namespace DbRepos;

public class FriendsDbRepos
{
    private ILogger<FriendsDbRepos> _logger;
    private readonly MainDbContext _dbContext;

    public FriendsDbRepos(ILogger<FriendsDbRepos> logger, MainDbContext context)
    {
        _logger = logger;
        _dbContext = context;
    }

    public async Task<ResponsePageDto<IFriend>> ReadFriendsAsync()
    {
        IQueryable<FriendDbM> query = _dbContext.Friends.AsNoTracking();
        var ret = new ResponsePageDto<IFriend>()
        {
#if DEBUG
            ConnectionString = _dbContext.dbConnection,
#endif
            DbItemsCount = await query.CountAsync(),
            PageItems = await query.ToListAsync<IFriend>(),
        };
        return ret;
    }
}
