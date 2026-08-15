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

    public Guid CardHolderId { get; set; }  //Enforces Cascade Delete


    #region correcting the Navigation properties migration error caused by using interfaces
    [ForeignKey("CardHolderId")]
    [JsonIgnore]
    public  FriendDbM CardHolderDbM { get; set; } = null;         
    
    [NotMapped]
    public override IFriend CardHolder { get => CardHolderDbM; set => new NotImplementedException(); }
    #endregion
    
    public new CreditCardDbM Seed(SeedGenerator seeder)
    {
        base.Seed(seeder);
        return this;
    }
}
