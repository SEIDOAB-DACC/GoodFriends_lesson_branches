namespace Models;

public enum CardIssues {AmericanExpress, Visa, MasterCard, DinersClub}

public interface ICreditCard
{
    public Guid CreditCardId { get; set; }

    public CardIssues Issuer { get; set; }
    public string Number { get; set; }
    public string ExpirationYear { get; set; }
    public string ExpirationMonth { get; set; }
}