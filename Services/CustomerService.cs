using Configuration;
using Microsoft.Extensions.Logging;
using Models;
using Seido.Utilities.SeedGenerator;
namespace Services;


public class CustomerService : ICustomerService {
    private readonly ILogger<CustomerService> _logger;
    private readonly Encryptions _encryptions;
    private readonly List<ICustomer> _customers;
    private readonly SeedGenerator _seeder = new SeedGenerator();

    public CustomerService(ILogger<CustomerService> logger, Encryptions encryptions)
    {
        _logger = logger;
        _encryptions = encryptions;

        _logger.LogInformation($"Randomly generating {1000} customers");
        var creditcards = _seeder.ItemsToList<CreditCard>(1000);
        var customers = _seeder.ItemsToList<Customer>(1000);

        for (int i = 0; i < customers.Count; i++)
        {
            customers[i].CreditCard = creditcards[i];
            customers[i].CreditCardEncrypted = _encryptions.AesEncryptToBase64<CreditCard>(creditcards[i]);
        }
        _customers = customers.ToList<ICustomer>();
    }

    public List<ICustomer> GetCustomers(int nrItems)
    {
        _logger.LogInformation($"Retrieving {nrItems} customers");
        
        return _customers.Take(Math.Min(nrItems, _customers.Count)).ToList();
    }
}