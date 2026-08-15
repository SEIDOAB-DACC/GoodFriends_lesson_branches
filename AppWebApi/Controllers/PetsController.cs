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
    public class PetsController : Controller
    {
        readonly IPetsService _service = null;
        readonly ILogger<PetsController> _logger = null;

        public PetsController(IPetsService service, ILogger<PetsController> logger)
        {
            _service = service;
            _logger = logger;
        }
    }
}

