namespace Models;

public class User : IUser
{
    public virtual Guid UserId { get; set; }

    public virtual string UserName { get; set; }
    public virtual string Email { get; set; }
    public virtual string Password { get; set; }

    public virtual string UserRole { get; set; }
}


