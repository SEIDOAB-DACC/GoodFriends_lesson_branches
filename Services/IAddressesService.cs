using Models;
using Models.DTO;

namespace Services;

public interface IAddressesService
{
    public Task<ResponsePageDto<IAddress>> ReadAddressesAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize);
    public Task<ResponseItemDto<IAddress>> ReadAddressAsync(Guid id, bool flat);
    public Task<ResponseItemDto<IAddress>> DeleteAddressAsync(Guid id);
    public Task<ResponseItemDto<IAddress>> UpdateAddressAsync(AddressCuDto item);
    public Task<ResponseItemDto<IAddress>> CreateAddressAsync(AddressCuDto item);
}
