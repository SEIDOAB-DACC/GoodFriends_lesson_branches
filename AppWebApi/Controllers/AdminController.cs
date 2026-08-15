using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Newtonsoft.Json;

using Microsoft.Extensions.Options;
using Seido.Utilities.SeedGenerator;
using Configuration.Options;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]   
    public class AdminController : Controller
    {
        readonly ILogger<AdminController> _logger;
        private readonly DbConnectionSetsOptions _dbSetOptions;
        readonly AesEncryptionOptions _aesOptions;
        readonly JwtOptions _jwtOptions;
        readonly VersionOptions _versionOptions;
        readonly IConfiguration _configuration;
        
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

        public AdminController(ILogger<AdminController> logger,
                    IConfiguration configuration,
                    IOptions<DbConnectionSetsOptions> dbSetOptions,
                    IOptions<AesEncryptionOptions> aesOptions,
                    IOptions<JwtOptions> jwtOptions,
                    IOptions<VersionOptions> versionOptions)
        {
            _logger = logger;

            _dbSetOptions = dbSetOptions.Value;
            _aesOptions = aesOptions.Value;
            _jwtOptions = jwtOptions.Value;
            _versionOptions = versionOptions.Value;
            _configuration = configuration;
        }
    }
}

