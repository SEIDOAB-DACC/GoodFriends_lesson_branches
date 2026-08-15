using Configuration;
using Models.DTO;
using Seido.Utilities.SeedGenerator;

namespace Models;

public class Animal : IAnimal
{
    public virtual Guid AnimalId { get; set; } = Guid.NewGuid();
    public AnimalKind Kind { get; set; }
    public AnimalMood Mood { get; set; }

    public string Name { get; set; }
    public virtual IZoo Zoo { get; set; }
    
    public IAnimal UpdateFromDto(AnimalDto dto)
    {
        AnimalId = dto.AnimalId;
        Kind = dto.Kind;
        Mood = dto.Mood;
        Name = dto.Name;
        return this;
    }
}