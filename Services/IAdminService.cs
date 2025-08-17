using Models;

namespace Services;

public interface IAdminService
{
    List<IQuote> Quotes();
    List<string> EncryptedQuotes();
    public IQuote DecryptedQuote(string encryptedQuote);
}
