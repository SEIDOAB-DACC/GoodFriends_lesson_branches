namespace Models.DTO;

public class FriendCuDto
{
    public virtual Guid? FriendId { get; set; }

    public virtual string FirstName { get; set; }
    public virtual string LastName { get; set; }

    public virtual string Email { get; set; }

    public DateTime? Birthday { get; set; } = null;

    public virtual Guid? AddressId { get; set; } = null;

    public virtual List<Guid> PetsId { get; set; } = null;

    public virtual List<Guid> QuotesId { get; set; } = null;

    public FriendCuDto() { }
    public FriendCuDto(IFriend org)
    {
        FriendId = org.FriendId;
        FirstName = org.FirstName;
        LastName = org.LastName;
        Email = org.Email;
        Birthday = org.Birthday;

        AddressId = org?.Address?.AddressId;
        PetsId = org.Pets?.Select(i => i.PetId).ToList();
        QuotesId = org.Quotes?.Select(i => i.QuoteId).ToList();
    }
}
