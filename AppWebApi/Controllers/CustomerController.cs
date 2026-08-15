using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Services;
using Models;

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    public class CustomerController : Controller
    {
        readonly ICustomerService _customerService;
        readonly ILogger<CustomerController> _logger;

        public CustomerController(ICustomerService customerService, ILogger<CustomerController> logger)
        {
            _customerService = customerService;
            _logger = logger;
        }

        //GET: api/customer/clear?nrItems=10
        [HttpGet()]
        [ActionName("Customers")]
        [ProducesResponseType(200, Type = typeof(List<ICustomer>))]
        public IActionResult Customers(int nrItems = 10)
        {
            try
            {
                var customers = _customerService.GetCustomers(nrItems);

                _logger.LogInformation($"{nameof(Customers)}: Retrieved {customers.Count} customers");
                return Ok(customers);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(Customers)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }

        //GET: api/customer/clearcreditcard?encryptedToken=abc123
        [HttpGet()]
        [ActionName("ClearCreditCard")]
            [ProducesResponseType(200, Type = typeof(CreditCard))]
        public IActionResult ClearCreditCard(string encryptedToken)
        {
            try
            {
                _logger.LogInformation($"{nameof(ClearCreditCard)}: Retrieved credit card details");

                var creditCard = _customerService.ClearCreditCard(encryptedToken);

                return Ok(creditCard);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(ClearCreditCard)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }
    }
}
