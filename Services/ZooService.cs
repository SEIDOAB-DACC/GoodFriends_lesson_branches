using DbRepos;
using Models;
namespace Services;

public class ZooServiceDb : IZooService
{
    private readonly ZooDbRepos _zooDbRepos;
    public Task<List<IZoo>> ReadZoos() => _zooDbRepos.ReadZoos();
 
    public ZooServiceDb(ZooDbRepos zooDbRepos)
    {
        _zooDbRepos = zooDbRepos;
    }
}