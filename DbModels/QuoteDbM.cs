using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Newtonsoft.Json;

using Seido.Utilities.SeedGenerator;
using Models;

namespace DbModels;

sealed public class QuoteDbM : Quote, IEquatable<QuoteDbM>
{
    [Key]
    public override Guid QuoteId { get; set; }

    #region constructors
    public QuoteDbM() : base() { }
    public QuoteDbM(SeededQuote goodQuote) : base(goodQuote) { }
    #endregion

    #region implementing IEquatable
    public bool Equals(QuoteDbM other) => (other != null) && ((QuoteText, Author) == (other.QuoteText, other.Author));
    public override bool Equals(object obj) => Equals(obj as QuoteDbM);
    public override int GetHashCode() => (QuoteText, Author).GetHashCode();
    #endregion
}


