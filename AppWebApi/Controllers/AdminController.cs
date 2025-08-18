using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Newtonsoft.Json;

using Models.DTO;
using Services;
using Configuration;
using Configuration.Options;
using Microsoft.Extensions.Options;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]

#if !DEBUG    
    [Authorize(AuthenticationSchemes = Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerDefaults.AuthenticationScheme,
       Policy = null, Roles = "dbo")]
#endif
    
    public class AdminController : Controller
    {
        readonly DatabaseConnections _dbConnections;
        readonly IAdminService _service;
        readonly ILogger<AdminController> _logger;
        readonly VersionOptions _versionOptions;

        //GET: api/admin/environment
        [HttpGet()]
        [ActionName("Environment")]
        [ProducesResponseType(200, Type = typeof(DatabaseConnections.SetupInformation))]
        public IActionResult Environment()
        {
            try
            {
                var info = _dbConnections.SetupInfo;

                _logger.LogInformation($"{nameof(Environment)}:\n{JsonConvert.SerializeObject(info)}");
                return Ok(info);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(Environment)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
         }

#if DEBUG
        //GET: api/admin/seed?count={count}
        [Authorize(AuthenticationSchemes = Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerDefaults.AuthenticationScheme,
          Policy = null, Roles = "dbo")]
        [HttpGet()]
        [ActionName("Seed")]
        [ProducesResponseType(200, Type = typeof(GstUsrInfoAllDto))]
        [ProducesResponseType(400, Type = typeof(string))]
        public async Task<IActionResult> Seed(string count = "100")
        {
            try
            {
                int countArg = int.Parse(count);

                _logger.LogInformation($"{nameof(Seed)}: {nameof(countArg)}: {countArg}");
                var info = await _service.SeedAsync(countArg);
                return Ok(info);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(Seed)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }

        //GET: api/admin/removeseed
        [Authorize(AuthenticationSchemes = Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerDefaults.AuthenticationScheme,
          Policy = null, Roles = "dbo")]
        [HttpGet()]
        [ActionName("RemoveSeed")]
        [ProducesResponseType(200, Type = typeof(GstUsrInfoAllDto))]
        [ProducesResponseType(400, Type = typeof(string))]
        public async Task<IActionResult> RemoveSeed(string seeded = "true")
        {
            try
            {
                bool seededArg = bool.Parse(seeded);

                _logger.LogInformation($"{nameof(RemoveSeed)}: {nameof(seededArg)}: {seededArg}");
                var info = await _service.RemoveSeedAsync(seededArg);
                return Ok(info);        
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(RemoveSeed)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }

        //You need to run this with dbo connection string but not logged in
        [HttpGet()]
        [ActionName("SeedUsers")]
        [ProducesResponseType(200, Type = typeof(UsrInfoDto))]
        [ProducesResponseType(400, Type = typeof(string))]
        public async Task<IActionResult> SeedUsers(string countUsr = "32", string countSupUsr = "2", string countDbOwners = "1")
        {
            try
            {
                int _countUsr = int.Parse(countUsr);
                int _countSupUsr = int.Parse(countSupUsr);
                int _countDbOwners = int.Parse(countDbOwners);

                _logger.LogInformation($"{nameof(SeedUsers)}: {nameof(_countUsr)}: {_countUsr}, {nameof(_countSupUsr)}: {_countSupUsr}, {nameof(_countDbOwners)}: {_countDbOwners}");

                var _info = await _service.SeedUsersAsync(_countUsr, _countSupUsr, _countDbOwners);
                return Ok(_info);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);  
            }       
        }
#endif
        [HttpGet()]
        [ActionName("Version")]
        [ProducesResponseType(typeof(VersionOptions), 200)]
        public IActionResult Version()
        {
            try
            {
                _logger.LogInformation($"{nameof(Version)}:\n{JsonConvert.SerializeObject(_versionOptions)}");
                return Ok(_versionOptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving version information");
                return BadRequest(ex.Message);
            }
        }
        //GET: api/admin/log
        [HttpGet()]
        [ActionName("Log")]
        [ProducesResponseType(200, Type = typeof(IEnumerable<LogMessage>))]
        public async Task<IActionResult> Log([FromServices] ILoggerProvider _loggerProvider)
        {
            //Note the way to get the LoggerProvider, not the logger from Services via DI
            if (_loggerProvider is InMemoryLoggerProvider cl)
            {
                return Ok(await cl.MessagesAsync);
            }
            return Ok("No messages in log");
        }

        public AdminController(IAdminService service, ILogger<AdminController> logger,
                DatabaseConnections dbConnections, IOptions<VersionOptions> versionOptions)
        {
            _service = service;
            _logger = logger;
            _dbConnections = dbConnections;
            _versionOptions = versionOptions.Value;
        }
    }
}

