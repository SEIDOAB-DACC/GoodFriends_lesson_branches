using Configuration;
using Seido.Utilities.SeedGenerator;

namespace Models.DTO;

public class AnimalDto
{
    public Guid AnimalId { get; set; } 
    public AnimalKind Kind { get; set; }
    public AnimalMood Mood { get; set; }

    public string Name { get; set; }    
    public Guid? ZooId { get; set; }
}