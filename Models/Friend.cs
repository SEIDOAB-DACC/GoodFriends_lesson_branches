using Seido.Utilities.SeedGenerator;

namespace Models;

public class Friend : IFriend
{
    public virtual Guid FriendId { get; set; }

    public virtual string FirstName { get; set; }
    public virtual string LastName { get; set; }

    public virtual string Email { get; set; }
    public DateTime? Birthday { get; set; } = null;

    //One Friends can only have one address
    public virtual IAddress Address { get; set; } = null;

    //One Friends can have many favorite pets
    public virtual List<IPet> Pets { get; set; } = null;

    //One Friends can have many favorite quotes
    public virtual List<IQuote> Quotes { get; set; } = null;


    public string FullName => $"{FirstName} {LastName}";

    public override string ToString()
    {
        var sRet = $"{FullName} [{FriendId}]";

        if (Address != null)
            sRet += $"\n  - Lives at {Address}";
        else
            sRet += $"\n  - Has no address";


        if (Pets != null && Pets.Count > 0)
        {
            sRet += $"\n  - Has pets";
            foreach (var pet in Pets)
            {
                sRet += $"\n     {pet}";
            }
        }
        else
            sRet += $"\n  - Has no pets";

        if (Birthday != null)
        {
            sRet += $"\n  - Has birthday on {Birthday:D}";
        }

        return sRet;
    }

    #region contructors
    public Friend() { }

    public Friend(Friend org)
    {
        this.FriendId = org.FriendId;
        this.FirstName = org.FirstName;
        this.LastName = org.LastName;
        this.Email = org.Email;

        //use the ternary operator to create only if the orginal is not null
        this.Address = (org.Address != null)? new Address((Address)org.Address): null;

        //using Linq Select and copy contructor to create a list copy
        this.Pets = (org.Pets != null) ? org.Pets.Select(p => new Pet((Pet) p)).ToList<IPet>() : null;
    }
    #endregion
}

