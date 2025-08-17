using Models;
using Models.DTO;

namespace Services;

public interface IPetsService
{
    public Task<ResponsePageDto<IPet>> ReadPetsAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize);
    public Task<ResponseItemDto<IPet>> ReadPetAsync(Guid id, bool flat);
    public Task<ResponseItemDto<IPet>> DeletePetAsync(Guid id);
    public Task<ResponseItemDto<IPet>> UpdatePetAsync(PetCuDto item);
    public Task<ResponseItemDto<IPet>> CreatePetAsync(PetCuDto item);
}
