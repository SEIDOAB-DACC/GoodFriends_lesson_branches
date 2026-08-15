using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using System.Data;

using Models;
using Models.DTO;
using DbModels;
using DbContext;

namespace DbRepos;

public class PetsDbRepos
{
    private ILogger<PetsDbRepos> _logger;
    private readonly MainDbContext _dbContext;

    public PetsDbRepos(ILogger<PetsDbRepos> logger, MainDbContext context)
    {
        _logger = logger;
        _dbContext = context;
    }

    public async Task<ResponsePageDto<IPet>> ReadPetsAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize)
    {
        filter ??= "";
        IQueryable<PetDbM> query;
        if (flat)
        {
            query = _dbContext.Pets.AsNoTracking();
        }
        else
        {
            query = _dbContext.Pets.AsNoTracking()
                .Include(i => i.FriendDbM)
                .ThenInclude(i => i.AddressDbM)
                .Include(i => i.FriendDbM)
                .ThenInclude(i => i.QuotesDbM);
        }

        var ret = new ResponsePageDto<IPet>()
        {
#if DEBUG
            ConnectionString = _dbContext.dbConnection,
#endif
            DbItemsCount = await query

            //Adding filter functionality
            .Where(i => (i.Seeded == seeded) && 
                        (i.Name.ToLower().Contains(filter))).CountAsync(),

            PageItems = await query

            //Adding filter functionality
            .Where(i => (i.Seeded == seeded) && 
                        (i.Name.ToLower().Contains(filter)))

            //Adding paging
            .Skip(pageNumber * pageSize)
            .Take(pageSize)

            .ToListAsync<IPet>(),

            PageNr = pageNumber,
            PageSize = pageSize
        };
        return ret;
    }
}
