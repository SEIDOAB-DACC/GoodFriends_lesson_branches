using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc;

using Models;
using Services;
using Microsoft.AspNetCore.Authorization;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    public class AddressesController : Controller
    {
        readonly IAddressesService _service;
        readonly ILogger<AddressesController> _logger;

        public AddressesController(IAddressesService service, ILogger<AddressesController> logger)
        {
            _service = service;
            _logger = logger;
        }
    }
}

