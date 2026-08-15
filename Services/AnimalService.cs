using DbRepos;
using Models;
using Models.DTO;
namespace Services;

public class AnimalServiceDb : IAnimalService
{
    private readonly AnimalDbRepos _animalDbRepos;

    public AnimalServiceDb(AnimalDbRepos animalDbRepos)
    {
        _animalDbRepos = animalDbRepos;
    }

    public Task<IAnimal> UpdateAnimalAsync(AnimalDto animalDto) => _animalDbRepos.UpdateAnimalAsync(animalDto);

}