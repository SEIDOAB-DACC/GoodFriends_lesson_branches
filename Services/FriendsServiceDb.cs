using Microsoft.Extensions.Logging;

using Models;
using Models.DTO;
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

    //Simple 1:1 calls in this case, but as Services expands, this will no longer need to be the case
    public Task<ResponsePageDto<IFriend>> ReadFriendsAsync() => _repo.ReadFriendsAsync();
}

