using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Newtonsoft.Json;

using Seido.Utilities.SeedGenerator;
using Models;

namespace DbModels;

public class ZooDbM : Zoo
{
    [Key]
    public override Guid ZooId { get; set; }

    [NotMapped]
    public override List<IAnimal> Animals { get => AnimalsDbM.ToList<IAnimal>(); set => throw new NotImplementedException(); }

    public List<AnimalDbM> AnimalsDbM { get; set; }

}