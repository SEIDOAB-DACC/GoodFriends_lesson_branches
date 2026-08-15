using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Newtonsoft.Json;

using Seido.Utilities.SeedGenerator;
using Models;

namespace DbModels;

public class AnimalDbM : Animal
{
    [Key]
    public override Guid AnimalId { get; set; }

    public string MoodString
    {
        get => Mood.ToString();
        set { }
    }

    [NotMapped]
    public override IZoo Zoo { get => ZooDbM; set => throw new NotImplementedException(); }

    [JsonIgnore]
    public ZooDbM ZooDbM { get; set; }
}