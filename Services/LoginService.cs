using Microsoft.Extensions.Logging;

using DbRepos;
using Models.DTO;
using DbContext;

namespace Services;

public class LoginService : ILoginService
{
    private readonly LoginDbRepos _repo;
    private readonly JWTService _jtwService;
    private readonly ILogger<LoginService> _logger;

    public LoginService(ILogger<LoginService> logger, LoginDbRepos repo, JWTService jtwService)
    {
        _repo = repo;
        _logger = logger;
        _jtwService = jtwService;
    }

    public async Task<ResponseItemDto<LoginUserSessionDto>> LoginUserAsync(LoginCredentialsDto usrCreds)
    {
        try
        {
            var _usrSession = await _repo.LoginUserAsync(usrCreds);

            //Successful login. Create a JWT token
            _usrSession.Item.JwtToken = _jtwService.CreateJwtUserToken(_usrSession.Item);

            //For test only, decypt the JWT token and compare.
            var _tmpUserSession = _jtwService.DecodeToken(_usrSession.Item.JwtToken.EncryptedToken);

            return _usrSession;
        }
        catch
        {
            //if there was an error during login, simply pass it on.
            throw;
        }
    }
}

