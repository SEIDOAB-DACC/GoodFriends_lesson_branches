using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Newtonsoft.Json;

using Configuration;
using Configuration.Options;

using Microsoft.Extensions.Options;
using AppWebApi.Models;
using Seido.Utilities.SeedGenerator;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]   
    public class AdminController : Controller
    {
        readonly Encryptions _encryptions = null;
        readonly DatabaseConnections _dbConnections = null;
        readonly ILogger<AdminController> _logger;
        private readonly DbConnectionSetsOptions _dbSetOptions;
        readonly AesEncryptionOptions _aesOptions;
        readonly JwtOptions _jwtOptions;
        readonly VersionOptions _versionOptions;
        readonly IConfiguration _configuration;

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

        //GET: api/admin/userconnection
        [HttpGet()]
        [ActionName("DefaultDataUserConnection")]
        [ProducesResponseType(200, Type = typeof(DbConnectionDetailOptions))]
        public IActionResult DefaultDataUserConnection()
        {
            try
            {
                var info = _dbConnections.GetDataConnectionDetails(_configuration["DatabaseConnections:DefaultDataUser"]);

                _logger.LogInformation($"{nameof(DefaultDataUserConnection)}:\n{JsonConvert.SerializeObject(info)}");
                return Ok(info);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(DefaultDataUserConnection)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }

        //GET: api/admin/migrationuserconnection
        [HttpGet()]
        [ActionName("MigrationUserConnection")]
        [ProducesResponseType(200, Type = typeof(DbConnectionDetailOptions))]
        public IActionResult MigrationUserConnection()
        {
            try
            {
                var info = _dbConnections.GetDataConnectionDetails(_configuration["DatabaseConnections:MigrationUser"]);

                _logger.LogInformation($"{nameof(MigrationUserConnection)}:\n{JsonConvert.SerializeObject(info)}");
                return Ok(info);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(MigrationUserConnection)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }

        //GET: api/admin/key
        [HttpGet()]
        [ActionName("Key")]
        [ProducesResponseType(200)]
        public IActionResult Key()
        {
            try
            {
                var keyOptions = new
                {
                    SecretStorage = _configuration["ApplicationSecrets:SecretStorage"],
                    MigrationUser = _configuration["DatabaseConnections:MigrationUser"],
                    DefaultDataUser = _configuration["DatabaseConnections:DefaultDataUser"],
                    UseDataSetWithTag = _configuration["DatabaseConnections:UseDataSetWithTag"],
                };
                return Ok(keyOptions);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        //GET: api/admin/options1
        [HttpGet()]
        [ActionName("Options1")]
        [ProducesResponseType(200, Type = typeof(DbConnectionSetsOptions))]
        public IActionResult Options1()
        {
            try
            {
                return Ok(_dbSetOptions);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        //GET: api/admin/options1
        [HttpGet()]
        [ActionName("Options2")]
        [ProducesResponseType(200, Type = typeof(AesEncryptionOptions))]
        public IActionResult Options2()
        {
            try
            {
                return Ok(_aesOptions);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        //GET: api/admin/options1
        [HttpGet()]
        [ActionName("Options3")]
        [ProducesResponseType(200, Type = typeof(JwtOptions))]
        public IActionResult Options3()
        {
            try
            {
                return Ok(_jwtOptions);
            }
            catch (Exception ex)
            {
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

                var quotes = new SeedGenerator().AllQuotes
                    .Select(goodQuote => new Quote(goodQuote))
                    .ToList<IQuote>();

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

                var quotes = new SeedGenerator().AllQuotes
                    .Select(goodQuote => new Quote(goodQuote))
                    .Select(q => _encryptions.AesEncryptToBase64<Quote>(q)).ToList();

                return Ok(quotes);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(EncryptedQuotes)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }

        //GET: api/admin/decryptedquote
        [HttpGet()]
        [ActionName("DecryptedQuote")]
        [ProducesResponseType(200, Type = typeof(List<IQuote>))]
        [ProducesResponseType(400, Type = typeof(string))]
        public IActionResult DecryptedQuote(string encryptedQuote)
        {
            try
            {
                _logger.LogInformation($"{nameof(DecryptedQuote)}");
                var decrypted = _encryptions.AesDecryptFromBase64<Quote>(encryptedQuote);

                return Ok(decrypted);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{nameof(DecryptedQuote)}: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }

        public AdminController(Encryptions encryptions, DatabaseConnections dbConnections, ILogger<AdminController> logger,
                    IConfiguration configuration,
                    IOptions<DbConnectionSetsOptions> dbSetOptions,
                    IOptions<AesEncryptionOptions> aesOptions,
                    IOptions<JwtOptions> jwtOptions,
                    IOptions<VersionOptions> versionOptions)
        {
            _encryptions = encryptions;
            _dbConnections = dbConnections;
            _logger = logger;

            _dbSetOptions = dbSetOptions.Value;
            _aesOptions = aesOptions.Value;
            _jwtOptions = jwtOptions.Value;
            _versionOptions = versionOptions.Value;
            _configuration = configuration;
        }
    }
}

