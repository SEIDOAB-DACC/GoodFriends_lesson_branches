using System.ComponentModel.DataAnnotations;
using Models;
using Seido.Utilities.SeedGenerator;

namespace DbModels;

public class CreditCardDbM : CreditCard, ISeed<CreditCardDbM>
{
    [Key]
    public override Guid CreditCardId { get; set; }

    public new CreditCardDbM Seed(SeedGenerator seeder)
    {
        base.Seed(seeder);
        return this;
    }
}
