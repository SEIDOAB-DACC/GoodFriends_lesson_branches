using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using System.Data;

using Models;
using DbModels;
using DbContext;

namespace DbRepos;

public class AddressesDbRepos
{
    private ILogger<AddressesDbRepos> _logger;
    private readonly MainDbContext _dbContext;

    public AddressesDbRepos(ILogger<AddressesDbRepos> logger, MainDbContext context)
    {
        _logger = logger;
        _dbContext = context;
    }
}
