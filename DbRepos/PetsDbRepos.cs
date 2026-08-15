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

    public async Task<ResponsePageDto<IPet>> ReadPetsAsync()
    {
        IQueryable<PetDbM> query = _dbContext.Pets.AsNoTracking();
        var ret = new ResponsePageDto<IPet>()
        {
#if DEBUG
            ConnectionString = _dbContext.dbConnection,
#endif
            DbItemsCount = await query.CountAsync(),
            PageItems = await query.ToListAsync<IPet>(),
        };
        return ret;
    }
}
