using Microsoft.Extensions.Logging;

using Models;
using Models.DTO;
using DbRepos;
using Configuration;

namespace Services;

public class CreditCardsService : ICreditCardsService
{
    private readonly ILogger<CreditCardsService> _logger = null;
    private Encryptions _encryptions;

    public CreditCardsService(ILogger<CreditCardsService> logger, Encryptions encryptions)
    {
        _logger = logger;
        _encryptions = encryptions;
    }

    //Simple 1:1 calls in this case, but as Services expands, this will no longer need to be the case
    public ICreditCard DecryptCreditCard(string encryptedToken)
    {
        return new CreditCard() { EncryptedToken = encryptedToken }.Decrypt(_encryptions.AesDecryptFromBase64<CreditCard>);
    }
}

