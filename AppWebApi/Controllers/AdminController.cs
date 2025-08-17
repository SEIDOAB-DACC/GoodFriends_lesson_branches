using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Newtonsoft.Json;

using Services;
using Configuration;
using Configuration.Options;

using Microsoft.Extensions.Options;
using Models;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]   
    public class AdminController : Controller
    {
        readonly IAdminService _service;
        readonly DatabaseConnections _dbConnections = null;
        readonly ILogger<AdminController> _logger;
        private readonly DbConnectionSetsOptions _dbSetOptions;
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

        //GET: api/admin/version
        [HttpGet()]
        [ActionName("Version")]
        [ProducesResponseType(typeof(VersionOptions), 200)]
        public IActionResult Version()
        {
            try
            {
                _logger.LogInformation($"{nameof(Environment)}:\n{JsonConvert.SerializeObject(_versionOptions)}");
                return Ok(_versionOptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving version information");
                return BadRequest(ex.Message);
            }
        }
        //GET: api/admin/quotes
        [HttpGet()]
        [ActionName("Quotes")]
        [ProducesResponseType(200, Type = typeof(List<IQuote>))]
        [ProducesResponseType(400, Type = typeof(string))]
        public IActionResult Quotes()
        {
            try
            {
                _logger.LogInformation($"{nameof(Quotes)}");
                var quotes = _service.Quotes();

                return Ok(quotes);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(Quotes)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }

        //GET: api/admin/encryptedquotes
        [HttpGet()]
        [ActionName("EncryptedQuotes")]
        [ProducesResponseType(200, Type = typeof(List<string>))]
        [ProducesResponseType(400, Type = typeof(string))]
        public IActionResult EncryptedQuotes()
        {
            try
            {
                _logger.LogInformation($"{nameof(EncryptedQuotes)}");
                var quotes = _service.EncryptedQuotes();

                return Ok(quotes);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(EncryptedQuotes)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }

        //GET: api/admin/decryptedquotes
        [HttpGet()]
        [ActionName("DecryptedQuote")]
        [ProducesResponseType(200, Type = typeof(IQuote))]
        [ProducesResponseType(400, Type = typeof(string))]
        public IActionResult DecryptedQuote(string encryptedQuote)
        {
            try
            {
                _logger.LogInformation($"{nameof(DecryptedQuote)}");
                var quote = _service.DecryptedQuote(encryptedQuote);

                return Ok(quote);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(DecryptedQuote)}: {ex.Message}");
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

        public AdminController(IAdminService service, DatabaseConnections dbConnections, ILogger<AdminController> logger,
        IOptions<VersionOptions> versionOptions)
        {
            _service = service;
            _dbConnections = dbConnections;
            _logger = logger;
            _dbConnections = dbConnections;
            _versionOptions = versionOptions.Value;
        }
    }
}

