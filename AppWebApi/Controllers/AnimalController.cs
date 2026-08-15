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
using Models.DTO;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    public class AnimalController : Controller
    {
        private readonly IAnimalService _animalService;

        public AnimalController(IAnimalService animalService)
        {
            _animalService = animalService;
        }
        
        [HttpPut()]
        [ProducesResponseType(200, Type = typeof(IAnimal))]
        [ProducesResponseType(400, Type = typeof(string))]
        public async Task<IActionResult> UpdateItem([FromBody] AnimalDto item)
        {
            try
            {
                IAnimal model = await _animalService.UpdateAnimalAsync(item);
                return Ok(model);
            }
            catch (Exception ex)
            {
                return BadRequest($"Could not update. Error {ex.InnerException?.Message}");
            }
        }

    }
}

