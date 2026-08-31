using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Newtonsoft.Json;

using Seido.Utilities.SeedGenerator;
using Models;

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