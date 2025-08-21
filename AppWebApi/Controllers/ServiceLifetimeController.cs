using Microsoft.AspNetCore.Mvc;
using Configuration;

namespace AppWebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ServiceLifetimeController : ControllerBase
    {
        private readonly LifeTimeService _lifetimeService;

        public ServiceLifetimeController(LifeTimeService emptyService)
        {
            _lifetimeService = emptyService;
        }

        // Service endpoints
        [HttpGet("multi-guid")]
        public ActionResult<Guid> MultiGuid([FromServices] LifeTimeService fromService1, [FromServices] LifeTimeService fromService2)
        {
            return Ok(new {
                _emptyService = _lifetimeService.GetGuid(),
                scopedService1 = fromService1.GetGuid(),
                scopedService2 = fromService2.GetGuid(),
                AreSame = _lifetimeService == fromService1 && _lifetimeService == fromService2
            });
        }
    }
}
