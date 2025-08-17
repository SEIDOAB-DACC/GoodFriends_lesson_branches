using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;

using Seido.Utilities.SeedGenerator;
using Models;

namespace DbModels;

sealed public class AddressDbM : Address, IEquatable<AddressDbM>
{
    [Key]     
    public override Guid AddressId { get; set; }

    public override string StreetAddress { get; set; }
    public override int ZipCode { get; set; }
    public override string City { get; set; }
    public override string Country { get; set; }

    #region implementing IEquatable
    public bool Equals(AddressDbM other) => (other != null) && ((StreetAddress, ZipCode, City, Country) ==
        (other.StreetAddress, other.ZipCode, other.City, other.Country));

    public override bool Equals(object obj) => Equals(obj as AddressDbM);
    public override int GetHashCode() => (StreetAddress, ZipCode, City, Country).GetHashCode();
    #endregion

    #region correcting the Navigation properties migration error caused by using interfaces
    [NotMapped] //removed from EFC 
    public override List<IFriend> Friends { get => FriendsDbM?.ToList<IFriend>(); set => new NotImplementedException(); }

    [JsonIgnore] //do not include in any json response from the WebApi
    public List<FriendDbM> FriendsDbM { get; set; } = null;
    #endregion

    #region constructors
    public AddressDbM() { }
    #endregion
}


