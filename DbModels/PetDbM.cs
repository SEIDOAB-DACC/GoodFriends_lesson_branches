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

    public override string Name { get; set; }
    
    #region removing the Navigation properties migration error caused by using interfaces

    [NotMapped]
    public override IFriend Friend { get; set; }        
    #endregion


    #region constructors
    public PetDbM() { }
    #endregion
}