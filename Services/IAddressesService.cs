using Models;
using Models.DTO;

namespace Services;

public interface IAddressesService
{
    public Task<ResponsePageDto<IAddress>> ReadAddressesAsync();
}
