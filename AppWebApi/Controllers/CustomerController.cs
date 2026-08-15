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
        [ActionName("Clear")]
        [ProducesResponseType(200, Type = typeof(List<ICustomer>))]
        public IActionResult Clear(int nrItems = 10)
        {
            try
            {
                var customers = _customerService.GetCustomers(nrItems);

                _logger.LogInformation($"{nameof(Clear)}: Retrieved {customers.Count} customers");
                return Ok(customers);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(Clear)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }

        //GET: api/customer/encrypted?nrItems=10
        [HttpGet()]
        [ActionName("Encrypted")]
        [ProducesResponseType(200, Type = typeof(List<ICustomer>))]
        public IActionResult Encrypted(int nrItems = 10)
        {
            try
            {
                var customers = _customerService.GetCustomers(nrItems);
                customers.ForEach(c =>
                {
                    c.CreditCard = null; //removing the credit card details
                });

                _logger.LogInformation($"{nameof(Encrypted)}: Retrieved {customers.Count} customers");
                return Ok(customers);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(Encrypted)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }
    }
}
