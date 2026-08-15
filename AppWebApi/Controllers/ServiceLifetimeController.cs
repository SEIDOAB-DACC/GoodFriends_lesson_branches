using Microsoft.AspNetCore.Mvc;
using Configuration;

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ServiceLifetimeController : ControllerBase
    {
        private readonly LifeTimeService _lifetimeService;
        private readonly IGreeter _greeter;

        public ServiceLifetimeController(LifeTimeService emptyService, IGreeter greeter)
        {
            _lifetimeService = emptyService;
            _greeter = greeter;
        }

        // Service endpoints
        [HttpGet("multi-guid")]
        public ActionResult<Guid> MultiGuid([FromServices] LifeTimeService fromService1, [FromServices] LifeTimeService fromService2)
        {
            return Ok(new
            {
                _emptyService = _lifetimeService.GetGuid(),
                scopedService1 = fromService1.GetGuid(),
                scopedService2 = fromService2.GetGuid(),
                AreSame = _lifetimeService == fromService1 && _lifetimeService == fromService2
            });
        }

        // Service endpoints
        [HttpGet("Greet")]
        public ActionResult<string> Greet()
        {

            return Ok(_greeter.Greeting());
        }
    }
}
