using Models;

namespace Services;

public interface ICustomerService {
    public List<ICustomer> GetCustomers(int nrItems);
}