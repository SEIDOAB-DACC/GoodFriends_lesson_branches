using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

using Models;
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

        public QuotesController(IQuotesService service, ILogger<QuotesController> logger)
        {
            _service = service;
            _logger = logger;
        }
    }
}

