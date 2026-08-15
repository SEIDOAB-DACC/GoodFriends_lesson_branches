using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using System.Data;

using Seido.Utilities.SeedGenerator;
using DbModels;
using DbContext;
using Configuration;

namespace DbRepos;

public class AdminDbRepos
{
    private const string _seedSource = "./app-seeds.json";
    private readonly ILogger<AdminDbRepos> _logger;
    private Encryptions _encryptions;
    private readonly MainDbContext _dbContext;

    public async Task SeedAsync(int nrItems)
    {

        var zoos = new List<ZooDbM>
        {
            new ZooDbM { ZooId = Guid.NewGuid(), Name = "Central Zoo", City = "Metropolis", Country = "Freedonia" },
            new ZooDbM { ZooId = Guid.NewGuid(), Name = "Safari Park", City = "Gotham", Country = "Freedonia" },
            new ZooDbM { ZooId = Guid.NewGuid(), Name = "Wildlife Reserve", City = "Star City", Country = "Freedonia" }
        };

        foreach (var zoo in zoos)
        {
            zoo.AnimalsDbM = new List<AnimalDbM>
            {
                new AnimalDbM { AnimalId = Guid.NewGuid(), Name = "Asterix", Kind = Models.AnimalKind.Zebra, Mood = Models.AnimalMood.Happy },
                new AnimalDbM { AnimalId = Guid.NewGuid(), Name = "Obelix", Kind = Models.AnimalKind.Leopard, Mood = Models.AnimalMood.Happy },
                new AnimalDbM { AnimalId = Guid.NewGuid(), Name = "Dogmatix", Kind = Models.AnimalKind.Elephant, Mood = Models.AnimalMood.Happy },
            };
        }

        //remove existing quotes in the database
        //_dbContext.Zoos.RemoveRange(_dbContext.Zoos);

        //Seeding new zoos into the database
        _dbContext.Zoos.AddRange(zoos);

        //Save changes to the database
        await _dbContext.SaveChangesAsync();
    }

    public AdminDbRepos(ILogger<AdminDbRepos> logger, Encryptions encryptions, MainDbContext context)
    {
        _logger = logger;
        _encryptions = encryptions;
        _dbContext = context;
    }
}
