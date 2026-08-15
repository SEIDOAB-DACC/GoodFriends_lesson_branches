using Models;
using Models.DTO;

namespace Services;

public interface IPetsService
{
    public Task<ResponsePageDto<IPet>> ReadPetsAsync();
}
