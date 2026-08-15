namespace Models;

public enum AnimalKind {Zebra, Elephant, Lion, Leopard, Gasell}
public enum AnimalMood { Happy, Hungry, Lazy, Sulky, Buzy, Sleepy };

public interface IAnimal
{
    public Guid AnimalId { get; set; }
    public AnimalKind Kind { get; set; }
    public AnimalMood Mood { get; set; }

    public string Name { get; set; }

    public IZoo Zoo { get; set; }
}
