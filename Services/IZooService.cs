using DbRepos;
using Models;
namespace Services;

public interface IZooService
{
    Task<List<IZoo>> ReadZoos();
}