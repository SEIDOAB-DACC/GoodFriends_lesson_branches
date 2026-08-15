using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Newtonsoft.Json;

using Seido.Utilities.SeedGenerator;
using Models;

namespace DbModels;
sealed public class PetDbM : Pet
{
    [Key]    
    public override Guid PetId { get; set; }

    public override string Name { get; set; }
    
    #region implementing entity Navigation properties when model is using interfaces in the relationships between models
    [JsonIgnore]
    public  FriendDbM FriendDbM { get; set; } = null;         
    
    [NotMapped]
    public override IFriend Friend { get => FriendDbM; set => new NotImplementedException(); }        
    #endregion


    #region constructors
    public PetDbM() { }
    #endregion
}