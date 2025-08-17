using Seido.Utilities.SeedGenerator;

namespace AppWebApi.Models;

public class Quote : IQuote, IEquatable<Quote>
{
    public virtual Guid QuoteId { get; set; }
    public virtual string QuoteText { get; set; }
    public virtual string Author { get; set; }

    #region constructors
    public Quote() { }

    public Quote(SeededQuote goodQuote)
    {
        QuoteId = Guid.NewGuid();
        QuoteText = goodQuote.Quote;
        Author = goodQuote.Author;
    }
    #endregion

    #region implementing IEquatable

    public bool Equals(Quote other) => (other != null) && ((QuoteText, Author) == (other.QuoteText, other.Author));
    public override bool Equals(object obj) => Equals(obj as Quote);
    public override int GetHashCode() => (QuoteText, Author).GetHashCode();

    #endregion
}


