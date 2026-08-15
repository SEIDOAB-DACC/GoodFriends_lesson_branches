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

    public async Task<ResponsePageDto<IAddress>> ReadAddressesAsync()
    {
        IQueryable<AddressDbM> query = _dbContext.Addresses.AsNoTracking();
        var ret = new ResponsePageDto<IAddress>()
        {
#if DEBUG
            ConnectionString = _dbContext.dbConnection,
#endif
            DbItemsCount = await query.CountAsync(),
            PageItems = await query.ToListAsync<IAddress>(),
        };
        return ret;
    }
}
