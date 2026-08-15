using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using System.Data;

using Models;

using DbModels;
using DbContext;

namespace DbRepos;

public class QuotesDbRepos
{
    private ILogger<QuotesDbRepos> _logger;
    private readonly MainDbContext _dbContext;

    public QuotesDbRepos(ILogger<QuotesDbRepos> logger, MainDbContext context)
    {
        _logger = logger;
        _dbContext = context;
    }
}