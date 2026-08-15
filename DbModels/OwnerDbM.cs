using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Models;
using Newtonsoft.Json;
using Seido.Utilities.SeedGenerator;

namespace DbModels;

public class OwnerDbM : Owner, ISeed<OwnerDbM>
{
    [Key]
    public override Guid OwnerId { get; set; }

    #region implementing entity Navigation properties when model is using interfaces in the relationships between models
    [NotMapped]
    public override List<ICreditCard> CreditCards { get => CreditCardsDbM.ToList<ICreditCard>(); set => throw new NotImplementedException(); }
    [JsonIgnore]
    public List<CreditCardDbM> CreditCardsDbM { get; set; }
    #endregion

    public new OwnerDbM Seed(SeedGenerator seeder)
    {
        base.Seed(seeder);
        return this;
    }
}
