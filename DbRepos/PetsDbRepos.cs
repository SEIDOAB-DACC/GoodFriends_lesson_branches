using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using System.Data;

using Models;
using DbModels;
using DbContext;

namespace DbRepos;

public class PetsDbRepos
{
    private ILogger<PetsDbRepos> _logger;
    private readonly MainDbContext _dbContext;

    public PetsDbRepos(ILogger<PetsDbRepos> logger, MainDbContext context)
    {
        _logger = logger;
        _dbContext = context;
    }
}
