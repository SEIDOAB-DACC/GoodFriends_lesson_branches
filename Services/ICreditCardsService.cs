using Models;
using Models.DTO;

namespace Services;

public interface ICreditCardsService
{
    ICreditCard DecryptCreditCard(string encryptedToken);
}


