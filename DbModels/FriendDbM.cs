using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Newtonsoft.Json;

using Seido.Utilities.SeedGenerator;
using Models;

namespace DbModels;

sealed public class FriendDbM : Friend
{
    [Key]    
    public override Guid FriendId { get; set; }
    
    public override string FirstName { get; set; }


    #region removing the Navigation properties migration error caused by using interfaces
    [NotMapped]
    public override IAddress Address { get; set; }
    
    [NotMapped]
    public override List<IPet> Pets { get; set; }

    [NotMapped]
    public override List<IQuote> Quotes { get; set; }
    #endregion

    #region constructors
    public FriendDbM() { }
    #endregion
}

