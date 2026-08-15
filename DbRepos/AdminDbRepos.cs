using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using System.Data;

using Seido.Utilities.SeedGenerator;
using Models.DTO;
using DbModels;
using DbContext;
using Configuration;

namespace DbRepos;

public class AdminDbRepos
{
    private const string _seedSource = "./app-seeds.json";
    private readonly ILogger<AdminDbRepos> _logger;
    private Encryptions _encryptions;
    private readonly MainDbContext _dbContext;

    public AdminDbRepos(ILogger<AdminDbRepos> logger, Encryptions encryptions, MainDbContext context)
    {
        _logger = logger;
        _encryptions = encryptions;
        _dbContext = context;
    }

    public async Task<ResponseItemDto<GstUsrInfoAllDto>> InfoAsync() => await DbInfo();

    private async Task<ResponseItemDto<GstUsrInfoAllDto>> DbInfo()
    {
        var info = new GstUsrInfoAllDto();
        info.Db = new GstUsrInfoDbDto
        {
            NrSeededFriends = await _dbContext.Friends.Where(f => f.Seeded).CountAsync(),
            NrUnseededFriends = await _dbContext.Friends.Where(f => !f.Seeded).CountAsync(),
            NrFriendsWithAddress = await _dbContext.Friends.Where(f => f.AddressId != null).CountAsync(),

            NrSeededAddresses = await _dbContext.Addresses.Where(f => f.Seeded).CountAsync(),
            NrUnseededAddresses = await _dbContext.Addresses.Where(f => !f.Seeded).CountAsync(),

            NrSeededPets = await _dbContext.Pets.Where(f => f.Seeded).CountAsync(),
            NrUnseededPets = await _dbContext.Pets.Where(f => !f.Seeded).CountAsync(),

            NrSeededQuotes = await _dbContext.Quotes.Where(f => f.Seeded).CountAsync(),
            NrUnseededQuotes = await _dbContext.Quotes.Where(f => !f.Seeded).CountAsync(),
        };

        return new ResponseItemDto<GstUsrInfoAllDto>
        {
#if DEBUG
            ConnectionString = _dbContext.dbConnection,
#endif

            Item = info
        };
    }

    public async Task<ResponseItemDto<GstUsrInfoAllDto>> SeedAsync(int nrOfItems)
    {
        //First of all make sure the database is cleared from all seeded data
        await RemoveSeedAsync(true);

        //Create a seeder
        var fn = Path.GetFullPath(_seedSource);
        var seeder = new SeedGenerator(fn);

        //Seeding the  quotes table
        var quotes = seeder.AllQuotes.Select(q => new QuoteDbM(q)).ToList();

        #region Full seeding
        //Generate friends and addresses
        var friends = seeder.ItemsToList<FriendDbM>(nrOfItems);
        var addresses = seeder.UniqueItemsToList<AddressDbM>(nrOfItems);

        //Assign Address, Pets and Quotes to all the friends
        foreach (var friend in friends)
        {
            friend.AddressDbM = (seeder.Bool) ? seeder.FromList(addresses) : null;
            friend.PetsDbM = seeder.ItemsToList<PetDbM>(seeder.Next(0, 4));
            friend.QuotesDbM = seeder.UniqueItemsPickedFromList(seeder.Next(0, 6), quotes);
        }

        //Note that all other tables are automatically set through FriendDbM Navigation properties
        _dbContext.Friends.AddRange(friends);
        #endregion

        LogChangeTracker();
        await _dbContext.SaveChangesAsync();
        LogChangeTracker();

        return await DbInfo();
    }

    public async Task<ResponseItemDto<GstUsrInfoAllDto>> RemoveSeedAsync(bool seeded)
    {
        _dbContext.Quotes.RemoveRange(_dbContext.Quotes.Where(f => f.Seeded == seeded));

        _dbContext.Pets.RemoveRange(_dbContext.Pets.Where(f => f.Seeded == seeded)); //not needed when DeleteBehavior.Cascade in MainDbContexts OnModelCreating
        _dbContext.Friends.RemoveRange(_dbContext.Friends.Where(f => f.Seeded == seeded));
        _dbContext.Addresses.RemoveRange(_dbContext.Addresses.Where(f => f.Seeded == seeded));

        LogChangeTracker();
        await _dbContext.SaveChangesAsync();
        LogChangeTracker();

        return await DbInfo();
    }

    // This method is for debugging purposes only and to demonstrate the ChangeTracker
    private void LogChangeTracker()
    {
        foreach (var e in _dbContext.ChangeTracker.Entries())
        {
            var id = e.Entity switch
            {
                QuoteDbM quoteDbM => quoteDbM.QuoteId,
                FriendDbM friendDbM => friendDbM.FriendId,
                AddressDbM addressDbM => addressDbM.AddressId,
                PetDbM petDbM => petDbM.PetId,
                _ => Guid.Empty
            };
            
            _logger.LogInformation($"{nameof(LogChangeTracker)}: {e.Entity.GetType().Name}: {id} - {e.State}");
        }
    }
}
