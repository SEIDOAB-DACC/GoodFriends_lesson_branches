using Microsoft.Extensions.Logging;

using Models;
using DbRepos;

namespace Services;

public class FriendsServiceDb : IFriendsService
{
    private readonly FriendsDbRepos _repo = null;
    private readonly ILogger<FriendsServiceDb> _logger = null;

    public FriendsServiceDb(FriendsDbRepos repo)
    {
        _repo = repo;
    }
    public FriendsServiceDb(FriendsDbRepos repo, ILogger<FriendsServiceDb> logger) : this(repo)
    {
        _logger = logger;
    }
}

