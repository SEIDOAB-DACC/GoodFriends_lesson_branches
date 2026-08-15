using DbRepos;
using Models;
using Models.DTO;
namespace Services;

public interface IAnimalService
{
    Task<IAnimal> UpdateAnimalAsync(AnimalDto animalDto);
}