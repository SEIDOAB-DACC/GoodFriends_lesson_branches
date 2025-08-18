using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Newtonsoft.Json;

using Seido.Utilities.SeedGenerator;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]   
    public class AdminController : Controller
    {
        readonly ILogger<AdminController> _logger;
        readonly IWebHostEnvironment _environment;
        readonly SeedGenerator _seeder = new SeedGenerator();

        //GET: api/admin/helloworld
        [HttpGet()]
        [ActionName("HelloWorld")]
        [ProducesResponseType(200)]
        public IActionResult HelloWorld()
        {
            try
            {
                var helloWorldOptions = new
                {
                    greeting = "Hello, World!",
                    from = "a friend",
                    time = DateTime.UtcNow
                };
                return Ok(helloWorldOptions);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        //GET: api/admin/version
        [HttpGet()]
        [ActionName("Version")]
        [ProducesResponseType(typeof(VersionInfo), 200)]
        public IActionResult Version()
        {
            try
            {
                var versionInfo = VersionInfo.FromAssembly();
                return Ok(versionInfo);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving version information");
                return BadRequest(ex.Message);
            }
        }


        public AdminController(ILogger<AdminController> logger, IWebHostEnvironment environment)
        {
            _logger = logger;
            _environment = environment;
        }
    }
}

