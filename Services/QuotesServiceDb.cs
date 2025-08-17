using Microsoft.Extensions.Logging;

using Models;
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
}

