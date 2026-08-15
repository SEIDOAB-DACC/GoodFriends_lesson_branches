using Configuration;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

using Models;
using Models.DTO;
using Services;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    public class CreditCardController : Controller
    {
        readonly ILogger<CreditCardController> _logger;
        private ICreditCardsService _creditCardsService;

        public CreditCardController(ILogger<CreditCardController> logger, ICreditCardsService creditCardsService)
        {
            _logger = logger;
            _creditCardsService = creditCardsService;
        }

        //GET: api/CreditCard/decrypt?encryptedToken=abc123
        [HttpGet()]
        [ActionName("Decrypt")]
        [ProducesResponseType(200, Type = typeof(ICreditCard))]
        public IActionResult Decrypt(string encryptedToken)
        {
            try
            {
                _logger.LogInformation($"{nameof(Decrypt)}: Retrieved credit card details");

                var creditCard = _creditCardsService.DecryptCreditCard(encryptedToken);
                return Ok(creditCard);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(Decrypt)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }
    }
}

