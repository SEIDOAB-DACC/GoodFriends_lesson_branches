using Seido.Utilities.SeedGenerator;

namespace Models;

public class Owner : IOwner, ISeed<Owner>
{
    public virtual Guid OwnerId { get; set; }

    public string FirstName { get; set; }
    public string LastName { get; set; }

    public virtual List<ICreditCard> CreditCards { get; set; }
    
    #region Seeder
    public bool Seeded { get; set; } = false;

    public Owner Seed (SeedGenerator seeder)
    {
        Seeded = true;
        OwnerId = Guid.NewGuid();

        FirstName = seeder.FirstName;
        LastName = seeder.LastName;

        return this;
    }
    #endregion
}

