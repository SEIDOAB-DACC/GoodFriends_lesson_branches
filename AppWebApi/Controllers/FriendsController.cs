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
    public class FriendsController : Controller
    {
        readonly IFriendsService _service = null;
        readonly ILogger<FriendsController> _logger = null;

        public FriendsController(IFriendsService service, ILogger<FriendsController> logger)
        {
            _service = service;
            _logger = logger;
        }
    }
}

