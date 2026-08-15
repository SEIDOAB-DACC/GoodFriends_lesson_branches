using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using System.Data;

using Seido.Utilities.SeedGenerator;
using DbModels;
using DbContext;
using Configuration;
using System.Threading.Tasks;
using Models;
using Models.DTO;

namespace DbRepos;

public class AnimalDbRepos
{
    private readonly MainDbContext _dbContext;

    public AnimalDbRepos(MainDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IAnimal> UpdateAnimalAsync(AnimalDto animalDto)
    {

        var animal = await _dbContext.Animals.Include(a => a.ZooDbM).FirstOrDefaultAsync(a => a.AnimalId == animalDto.AnimalId);
        if (animal == null) throw new Exception("Animal not found");

        animal.UpdateFromDto(animalDto);

        var zoo = (animalDto.ZooId != null) ? await _dbContext.Zoos.FindAsync(animalDto.ZooId.Value) : null;
        animal.ZooDbM = zoo;

        _dbContext.Animals.Update(animal);

        await _dbContext.SaveChangesAsync();
        return animal;
    }
}