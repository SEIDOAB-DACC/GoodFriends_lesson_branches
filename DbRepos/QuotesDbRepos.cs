using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using System.Data;

using Models;
using Models.DTO;
using DbModels;
using DbContext;

namespace DbRepos;

public class QuotesDbRepos
{
    private ILogger<QuotesDbRepos> _logger;
    private readonly MainDbContext _dbContext;

    public QuotesDbRepos(ILogger<QuotesDbRepos> logger, MainDbContext context)
    {
        _logger = logger;
        _dbContext = context;
    }

    public async Task<ResponsePageDto<IQuote>> ReadQuotesAsync()
    {
        IQueryable<QuoteDbM> query = _dbContext.Quotes.AsNoTracking();
        var ret = new ResponsePageDto<IQuote>()
        {
#if DEBUG
            ConnectionString = _dbContext.dbConnection,
#endif
            DbItemsCount = await query.CountAsync(),
            PageItems = await query.ToListAsync<IQuote>(),
        };
        return ret;
    }
}