using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Newtonsoft.Json;

using Seido.Utilities.SeedGenerator;
using Models;

namespace DbModels;
[Table("Pets", Schema = "supusr")]
sealed public class PetDbM : Pet
{
    [Key]    
    public override Guid PetId { get; set; }

    [JsonIgnore]
    public Guid FriendId { get; set; }  //Enforces Cascade Delete
    //public Guid? FriendId { get; set; }  //Enforces Cascade SetNull

    public override string Name { get; set; }
    
    #region correcting the Navigation properties migration error caused by using interfaces
    [ForeignKey("FriendId")]     
    [JsonIgnore]
    public  FriendDbM FriendDbM { get; set; } = null;         
    
    [NotMapped]
    public override IFriend Friend { get => FriendDbM; set => new NotImplementedException(); }        
    #endregion


    #region constructors
    public PetDbM() { }
    #endregion
}