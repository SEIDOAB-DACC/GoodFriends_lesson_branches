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

    public async Task<ResponsePageDto<IQuote>> ReadQuotesAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize)
    {
        filter ??= "";
        IQueryable<QuoteDbM> query;
        if (flat)
        {
            query = _dbContext.Quotes.AsNoTracking();
        }
        else
        {
            query = _dbContext.Quotes.AsNoTracking()
                .Include(i => i.FriendsDbM)
                .ThenInclude(i => i.PetsDbM)
                .Include(i => i.FriendsDbM)
                .ThenInclude(i => i.AddressDbM);

        }

        var ret = new ResponsePageDto<IQuote>()
        {
#if DEBUG
            ConnectionString = _dbContext.dbConnection,
#endif
            DbItemsCount = await query

            //Adding filter functionality
            .Where(i => (i.Seeded == seeded) &&
                        (i.QuoteText.ToLower().Contains(filter) ||
                            i.Author.ToLower().Contains(filter))).CountAsync(),

            PageItems = await query

            //Adding filter functionality
            .Where(i => (i.Seeded == seeded) &&
                        (i.QuoteText.ToLower().Contains(filter) ||
                            i.Author.ToLower().Contains(filter)))

            //Adding paging
            .Skip(pageNumber * pageSize)
            .Take(pageSize)

            .ToListAsync<IQuote>(),

            PageNr = pageNumber,
            PageSize = pageSize
        };
        return ret;
    }
}
