using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Newtonsoft.Json;

using Seido.Utilities.SeedGenerator;
using Models;
using Models.DTO;

namespace DbModels;
[Table("Pets", Schema = "supusr")]
sealed public class PetDbM : Pet, ISeed<PetDbM>
{
    [Key]    
    public override Guid PetId { get; set; }

    [JsonIgnore]
    public Guid FriendId { get; set; }  //Enforces Cascade Delete
    //public Guid? FriendId { get; set; }  //Enforces Cascade SetNull

    [Required]
    public override string Name { get; set; }
    
    #region correcting the Navigation properties migration error caused by using interfaces
    [ForeignKey("FriendId")]     
    [JsonIgnore]
    public  FriendDbM FriendDbM { get; set; } = null;         
    
    [NotMapped]
    public override IFriend Friend { get => FriendDbM; set => new NotImplementedException(); }        
    #endregion

    #region randomly seed this instance
    public override PetDbM Seed(SeedGenerator sgen)
    {
        base.Seed(sgen);
        return this;
    }
    #endregion


    #region constructors
    public PetDbM() { }
    #endregion
}