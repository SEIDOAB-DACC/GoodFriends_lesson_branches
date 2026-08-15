using Microsoft.Extensions.Logging;

using Models;
using Models.DTO;
using DbRepos;

namespace Services;

public class QuotesServiceDb : IQuotesService
{
    private readonly QuotesDbRepos _repo = null;
    private readonly ILogger<QuotesServiceDb> _logger = null;

    public QuotesServiceDb(QuotesDbRepos repo)
    {
        _repo = repo;
    }
    public QuotesServiceDb(QuotesDbRepos repo, ILogger<QuotesServiceDb> logger):this(repo)
    {
        _logger = logger;
    }
    
    //Simple 1:1 calls in this case, but as Services expands, this will no longer need to be the case
    public Task<ResponsePageDto<IQuote>> ReadQuotesAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize) => _repo.ReadQuotesAsync(seeded, flat, filter, pageNumber, pageSize);
}

