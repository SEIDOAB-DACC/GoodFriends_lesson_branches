using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using System.Data;

using Models;
using DbModels;
using DbContext;

namespace DbRepos;

public class FriendsDbRepos
{
    private ILogger<FriendsDbRepos> _logger;
    private readonly MainDbContext _dbContext;
}
