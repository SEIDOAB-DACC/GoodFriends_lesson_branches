using Microsoft.Extensions.Logging;

using Models;
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
}

