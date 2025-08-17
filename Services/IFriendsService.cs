using Models;
using Models.DTO;

namespace Services;

public interface IFriendsService
{
    public Task<ResponsePageDto<IFriend>> ReadFriendsAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize);
}


