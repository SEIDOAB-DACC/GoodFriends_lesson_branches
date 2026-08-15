using Models;
using Models.DTO;

namespace Services;

public interface IFriendsService
{
    public Task<ResponsePageDto<IFriend>> ReadFriendsAsync();
}


