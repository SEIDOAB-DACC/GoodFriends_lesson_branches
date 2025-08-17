using Microsoft.Extensions.Logging;

using Models;
using DbRepos;

namespace Services;

public class PetsServiceDb : IPetsService
{
    private readonly PetsDbRepos _repo = null;
    private readonly ILogger<PetsServiceDb> _logger = null;

    public PetsServiceDb(PetsDbRepos repo)
    {
        _repo = repo;
    }
    public PetsServiceDb(PetsDbRepos repo, ILogger<PetsServiceDb> logger):this(repo)
    {
        _logger = logger;
    }
}

