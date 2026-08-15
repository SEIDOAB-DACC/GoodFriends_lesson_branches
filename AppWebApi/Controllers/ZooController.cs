using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Newtonsoft.Json;

using Services;
using Configuration;
using Configuration.Options;
using Microsoft.Extensions.Options;
using System.ComponentModel;
using Models;
using System.Threading.Tasks;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]   
    public class ZooController : Controller
    {
        private readonly IZooService _zooService;
        
        //GET: api/admin/Read
        [HttpGet()]
        [ActionName("Read")]
        [ProducesResponseType(200, Type = typeof(List<Zoo>))]
        public async Task<IActionResult> Read()
        {
            try
            {
                List<IZoo> zoos = await _zooService.ReadZoos();
                return Ok(zoos);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
         }


        public ZooController(IZooService zooService)
        {
            _zooService = zooService;
        }
    }
}

