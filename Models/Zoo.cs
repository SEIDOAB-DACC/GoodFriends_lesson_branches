namespace Models;

public class Zoo : IZoo
{
    public virtual Guid ZooId { get; set; }
    public string Name { get; set; }
    public string City { get; set; }
    public string Country { get; set; }

    public virtual List<IAnimal> Animals { get; set; }
}