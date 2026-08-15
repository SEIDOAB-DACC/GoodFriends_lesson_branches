using Models;
using Models.DTO;

namespace Services;

public interface IAddressesService
{
    public Task<ResponsePageDto<IAddress>> ReadAddressesAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize);
}
