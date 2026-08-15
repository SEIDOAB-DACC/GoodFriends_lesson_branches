using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using System.Data;

using Seido.Utilities.SeedGenerator;
using DbModels;
using DbContext;
using Configuration;
using System.Threading.Tasks;
using Models;

namespace DbRepos;

public class ZooDbRepos
{
    private readonly MainDbContext _dbContext;

    public ZooDbRepos(MainDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<List<IZoo>> ReadZoos()
    {
        var zoos = await _dbContext.Zoos.Include(z => z.AnimalsDbM).ToListAsync();

        return zoos.ToList<IZoo>();
    }
}