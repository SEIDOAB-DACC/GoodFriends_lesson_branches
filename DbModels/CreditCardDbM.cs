using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Models;
using Newtonsoft.Json;
using Seido.Utilities.SeedGenerator;

namespace DbModels;

public class CreditCardDbM : CreditCard, ISeed<CreditCardDbM>
{
    [Key]
    public override Guid CreditCardId { get; set; }

    #region implementing entity Navigation properties when model is using interfaces in the relationships between models
    [NotMapped]
    public override IOwner Owner { get => OwnerDbM; set => throw new NotImplementedException(); }
    [JsonIgnore]
    public OwnerDbM OwnerDbM { get; set; }
    #endregion

    public new CreditCardDbM Seed(SeedGenerator seeder)
    {
        base.Seed(seeder);
        return this;
    }
}
