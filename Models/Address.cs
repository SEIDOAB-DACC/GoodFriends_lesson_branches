using Seido.Utilities.SeedGenerator;

namespace Models;

public class Address : IAddress, IEquatable<Address>
{
    public virtual Guid AddressId { get; set; }

    public virtual string StreetAddress { get; set; }
    public virtual int ZipCode { get; set; }
    public virtual string City { get; set; }
    public virtual string Country { get; set; }

    public override string ToString() => $"{StreetAddress}, {ZipCode} {City}, {Country}";

    public virtual List<IFriend> Friends { get; set; } = null;

    #region constructors
    public Address() { }
    public Address(Address org)
    {
        this.AddressId = org.AddressId;
        this.StreetAddress = org.StreetAddress;
        this.ZipCode = org.ZipCode;
        this.City = org.City;
        this.Country = org.Country;
    }
    #endregion

    #region implementing IEquatable

    public bool Equals(Address other) => (other != null) && ((this.StreetAddress, this.ZipCode, this.City, this.Country) ==
        (other.StreetAddress, other.ZipCode, other.City, other.Country));

    public override bool Equals(object obj) => Equals(obj as Address);
    public override int GetHashCode() => (StreetAddress, ZipCode, City, Country).GetHashCode();

    #endregion
}


