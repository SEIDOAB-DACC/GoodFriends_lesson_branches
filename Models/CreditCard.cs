using System.Security.Cryptography;
using System.Text.RegularExpressions;
using Configuration;
using Newtonsoft.Json;
using Seido.Utilities.SeedGenerator;

namespace Models;

public class CreditCard : ICreditCard, ISeed<CreditCard>
{
    public virtual Guid CreditCardId { get; set; }

    public CardIssues Issuer { get; set; }
    public string IssuerString => Issuer.ToString();
    
    public string Number { get; set; }
    public string ExpirationYear { get; set; }
    public string ExpirationMonth { get; set; }

    //when doing obfuscation
    public string EncryptedToken { get; set; }

    //One card can only have one Card Holder
    public virtual IFriend CardHolder { get; set; }
    

    #region Seeder
    public bool Seeded { get; set; } = false;

    public virtual CreditCard Seed (SeedGenerator seeder)
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

    //when doing obfuscation
    public CreditCard EnryptAndObfuscate(Func<CreditCard, string> encryptor)
    {
        this.EncryptedToken = encryptor(this);

        string pattern = @"\b(\d{4}[-\s]?)(\d{4}[-\s]?)(\d{4}[-\s]?)(\d{4})\b";
        string replacement = "$1**** **** **** $4";
        this.Number = Regex.Replace(Number, pattern, replacement);

        this.ExpirationYear = "**";
        this.ExpirationMonth = "**";

        return this;
    }

    //when doing obfuscation
    public CreditCard Decrypt(Func<string, CreditCard> decryptor)
    {
        return decryptor(this.EncryptedToken);
    }
}