namespace Models;

public enum WorkRole {AnimalCare, Veterinarian, ProgramCoordinator, Maintenance, Management}

public interface ICustomer
{
    public Guid CustomerId { get; set; }

    public string FirstName { get; set; }
    public string LastName { get; set; }

    public ICreditCard CreditCard { get; set; }
}