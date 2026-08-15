using Models;
using Models.DTO;

namespace Services;

public interface IFriendsService
{
    public Task<ResponsePageDto<IFriend>> ReadFriendsAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize);
    public Task<ResponseItemDto<IFriend>> ReadFriendAsync(Guid id, bool flat);
    public Task<ResponseItemDto<IFriend>> DeleteFriendAsync(Guid id);
    public Task<ResponseItemDto<IFriend>> UpdateFriendAsync(FriendCuDto item);
    public Task<ResponseItemDto<IFriend>> CreateFriendAsync(FriendCuDto item);
}


