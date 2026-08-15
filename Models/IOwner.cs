namespace Models;

public interface IOwner
{
    public Guid OwnerId { get; set; }

    public string FirstName { get; set; }
    public string LastName { get; set; }

    public List<ICreditCard> CreditCards { get; set; }
}


