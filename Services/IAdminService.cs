using Models.DTO;

namespace Services;

public interface IAdminService
{
    public Task<ResponseItemDto<GstUsrInfoAllDto>> GuestInfoAsync();
    public Task<ResponseItemDto<GstUsrInfoAllDto>> SeedAsync(int nrOfItems);
    public Task<ResponseItemDto<GstUsrInfoAllDto>> RemoveSeedAsync(bool seeded);
    public Task<ResponseItemDto<UsrInfoDto>> SeedUsersAsync(int nrOfUsers, int nrOfSuperUsers, int nrOfSysAdmin);
}
