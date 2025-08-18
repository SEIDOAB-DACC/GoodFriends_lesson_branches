namespace Models.DTO;

public class LoginCredentialsDto
{
    public string UserNameOrEmail { get; set; } 
    public string Password { get; set; }
}

public class LoginUserSessionDto
{
    public Guid? UserId { get; set; }
    public string UserName { get; set; }
    public string UserRole { get; set; }
    public JwtUserToken JwtToken { get; set; }
}


