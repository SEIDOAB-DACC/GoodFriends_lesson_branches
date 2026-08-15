namespace Models;

public interface IZoo
{
    public Guid ZooId { get; set; }
    public string Name { get; set; }
    public string City { get; set; }
    public string Country { get; set; }

    public List<IAnimal> Animals { get; set; }
}