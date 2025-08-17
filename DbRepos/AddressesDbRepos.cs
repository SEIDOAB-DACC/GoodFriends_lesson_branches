using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using System.Data;

using Models;
using Models.DTO;
using DbModels;
using DbContext;

namespace DbRepos;

public class AddressesDbRepos
{
    private ILogger<AddressesDbRepos> _logger;
    private readonly MainDbContext _dbContext;

    public AddressesDbRepos(ILogger<AddressesDbRepos> logger, MainDbContext context)
    {
        _logger = logger;
        _dbContext = context;
    }

    public async Task<ResponsePageDto<IAddress>> ReadAddressesAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize)
    {
        filter ??= "";
        IQueryable<AddressDbM> query;
        if (flat)
        {
            query = _dbContext.Addresses.AsNoTracking();
        }
        else
        {
            query = _dbContext.Addresses.AsNoTracking()
                .Include(i => i.FriendsDbM)
                .ThenInclude(i => i.PetsDbM)
                .Include(i => i.FriendsDbM)
                .ThenInclude(i => i.QuotesDbM);
        }

        var ret = new ResponsePageDto<IAddress>()
        {
#if DEBUG
            ConnectionString = _dbContext.dbConnection,
#endif
            DbItemsCount = await query

            //Adding filter functionality
            .Where(i => (i.Seeded == seeded) && 
                        (i.StreetAddress.ToLower().Contains(filter) ||
                            i.City.ToLower().Contains(filter) ||
                            i.Country.ToLower().Contains(filter))).CountAsync(),

            PageItems = await query

            //Adding filter functionality
            .Where(i => (i.Seeded == seeded) && 
                        (i.StreetAddress.ToLower().Contains(filter) ||
                            i.City.ToLower().Contains(filter) ||
                            i.Country.ToLower().Contains(filter)))

            //Adding paging
            .Skip(pageNumber * pageSize)
            .Take(pageSize)

            .ToListAsync<IAddress>(),

            PageNr = pageNumber,
            PageSize = pageSize
        };
        return ret;
    }
}
