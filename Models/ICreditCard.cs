using Seido.Utilities.SeedGenerator;

namespace Models;


public enum CardIssues
{
    Visa,
    Mastercard,
    Discover,
    AmericanExpress
}
public interface ICreditCard
{
    public Guid CreditCardId { get; set; }

    public CardIssues Issuer { get; set; }
    public string Number { get; set; }
    public string ExpirationYear { get; set; }
    public string ExpirationMonth { get; set; }    

    public string CardHolderName { get; set; }
}