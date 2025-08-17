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

    public async Task<ResponsePageDto<IFriend>> ReadFriendsAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize)
    {
        filter ??= "";
        IQueryable<FriendDbM> query;
        if (flat)
        {
            query = _dbContext.Friends.AsNoTracking();
        }
        else
        {
            query = _dbContext.Friends.AsNoTracking()
                .Include(i => i.AddressDbM)
                .Include(i => i.PetsDbM)
                .Include(i => i.QuotesDbM);
        }

        var ret = new ResponsePageDto<IFriend>()
        {
#if DEBUG
            ConnectionString = _dbContext.dbConnection,
#endif
            DbItemsCount = await query

            //Adding filter functionality
            .Where(i => (i.Seeded == seeded) &&
                        (i.FirstName.ToLower().Contains(filter) ||
                            i.LastName.ToLower().Contains(filter))).CountAsync(),

            PageItems = await query

            //Adding filter functionality
            .Where(i => (i.Seeded == seeded) &&
                        (i.FirstName.ToLower().Contains(filter) ||
                            i.LastName.ToLower().Contains(filter)))

            //Adding paging
            .Skip(pageNumber * pageSize)
            .Take(pageSize)

            .ToListAsync<IFriend>(),

            PageNr = pageNumber,
            PageSize = pageSize
        };
        return ret;
    }
}
