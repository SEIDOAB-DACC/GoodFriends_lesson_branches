using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

using Models;
using Models.DTO;
using Services;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    public class QuotesController : Controller
    {
        readonly IQuotesService _service = null;
        readonly ILogger<QuotesController> _logger = null;

        //GET: api/quotes/read
        [HttpGet()]
        [ActionName("Read")]
        [ProducesResponseType(200, Type = typeof(ResponsePageDto<IQuote>))]
        [ProducesResponseType(400, Type = typeof(string))]
        public async Task<IActionResult> Read()
        {
            try
            {
                _logger.LogInformation($"{nameof(Read)}");
                var resp = await _service.ReadQuotesAsync();     
                return Ok(resp);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(Read)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }

        public QuotesController(IQuotesService service, ILogger<QuotesController> logger)
        {
            _service = service;
            _logger = logger;
        }
    }
}

