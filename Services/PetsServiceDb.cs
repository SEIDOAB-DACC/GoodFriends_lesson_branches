using Microsoft.Extensions.Logging;

using Models;
using Models.DTO;
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
    
    //Simple 1:1 calls in this case, but as Services expands, this will no longer need to be the case
    public Task<ResponsePageDto<IPet>> ReadPetsAsync() => _repo.ReadPetsAsync();
}

