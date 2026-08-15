using Microsoft.Extensions.Logging;

using DbRepos;
using Models.DTO;
using DbContext;

namespace Services;

public class LoginService : ILoginService
{
    private readonly LoginDbRepos _repo;
    private readonly ILogger<LoginService> _logger;

    public LoginService(ILogger<LoginService> logger, LoginDbRepos repo)
    {
        _repo = repo;
        _logger = logger;
    }

    public async Task<ResponseItemDto<LoginUserSessionDto>> LoginUserAsync(LoginCredentialsDto usrCreds)
    {
        try
        {
            var _usrSession = await _repo.LoginUserAsync(usrCreds);
            return _usrSession;
        }
        catch
        {
            //if there was an error during login, simply pass it on.
            throw;
        }
    }
}

