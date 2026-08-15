using Seido.Utilities.SeedGenerator;

namespace Models;


public class CreditCard : ICreditCard, ISeed<CreditCard>
{
    public virtual Guid CreditCardId { get; set; }

    public CardIssues Issuer { get; set; }
    public string Number { get; set; }
    public string ExpirationYear { get; set; }
    public string ExpirationMonth { get; set; }    

    public string EncryptedToken { get; set; } //AES encrypted version of the cc

    public virtual IOwner Owner { get; set; }

    #region Seeder
    public bool Seeded { get; set; } = false;

    public CreditCard Seed (SeedGenerator seeder)
    {
        Seeded = true;
        CreditCardId = Guid.NewGuid();
        
        Issuer = seeder.FromEnum<CardIssues>();

        Number = $"{seeder.Next(2222, 9999)}-{seeder.Next(2222, 9999)}-{seeder.Next(2222, 9999)}-{seeder.Next(2222, 9999)}";
        ExpirationYear = $"{seeder.Next(25, 32)}";
        ExpirationMonth = $"{seeder.Next(01, 13):D2}";

        return this;
    }
    #endregion
}