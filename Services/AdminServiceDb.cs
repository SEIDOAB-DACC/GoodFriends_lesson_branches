using Microsoft.Extensions.Logging;

using Configuration;
using Models;
using Seido.Utilities.SeedGenerator;

namespace Services;
    
public class AdminServiceDb : IAdminService
{
    private readonly Encryptions _encryptions = null;
    private readonly ILogger<AdminServiceDb> _logger = null;

    public List<IQuote> Quotes()
    { 
        var quotes = new SeedGenerator().AllQuotes
            .Select(goodQuote => new Quote(goodQuote))
            .ToList<IQuote>();
        return quotes;
    }

    public List<string> EncryptedQuotes()
    { 
        var quotes = new SeedGenerator().AllQuotes
            .Select(goodQuote => new Quote(goodQuote))
            .Select(q => _encryptions.AesEncryptToBase64<Quote>(q)).ToList();
        return quotes;
    }

    public IQuote DecryptedQuote(string encryptedQuote)
    {
        var decrypted = _encryptions.AesDecryptFromBase64<Quote>(encryptedQuote);
        return decrypted;
    }

    #region constructors
    public AdminServiceDb(Encryptions encryptions)
    {
        _encryptions = encryptions;
    }
    public AdminServiceDb(Encryptions encryptions, ILogger<AdminServiceDb> logger):this(encryptions)
    {
        _logger = logger;
    }
    #endregion
}

