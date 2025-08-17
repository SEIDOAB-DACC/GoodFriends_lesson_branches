using Microsoft.Extensions.Logging;

using Models;
using Models.DTO;
using DbRepos;

namespace Services;

public class AddressesServiceDb : IAddressesService
{
    private readonly AddressesDbRepos _repo = null;
    private readonly ILogger<AddressesServiceDb> _logger = null;


    public AddressesServiceDb(AddressesDbRepos repo)
    {
        _repo = repo;
    }
    public AddressesServiceDb(AddressesDbRepos repo, ILogger<AddressesServiceDb> logger):this(repo)
    {
        _logger = logger;
    }
    
    //Simple 1:1 calls in this case, but as Services expands, this will no longer need to be the case
    public Task<ResponsePageDto<IAddress>> ReadAddressesAsync() => _repo.ReadAddressesAsync();
}

