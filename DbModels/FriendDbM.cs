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

    public Guid? AddressId { get; set; }

    #region correcting the Navigation properties migration error caused by using interfaces
    [NotMapped]
    public override IAddress Address { get => AddressDbM; set => new NotImplementedException(); }
    
    [JsonIgnore]
    [ForeignKey("AddressId")]
    public AddressDbM AddressDbM { get; set; } = null;    //This is implemented in the database table

    [NotMapped]
    public override List<IPet> Pets { get => PetsDbM?.ToList<IPet>(); set => new NotImplementedException(); }

    [JsonIgnore]
    public List<PetDbM> PetsDbM { get; set; } = null;

    [NotMapped] 
    public override List<IQuote> Quotes { get => QuotesDbM?.ToList<IQuote>(); set => new NotImplementedException(); }

    [JsonIgnore]
    public List<QuoteDbM> QuotesDbM { get; set; } = null;
    #endregion

    #region constructors
    public FriendDbM() { }
    #endregion
}

