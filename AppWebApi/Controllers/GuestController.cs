using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Newtonsoft.Json;

using Services;
using System.Text.RegularExpressions;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    public class GuestController : Controller
    {
        readonly IAdminService _service;
        readonly ILogger<GuestController> _logger = null;

        public GuestController(IAdminService service, ILogger<GuestController> logger)
        {
            _service = service;
            _logger = logger;
        }
    }
}

