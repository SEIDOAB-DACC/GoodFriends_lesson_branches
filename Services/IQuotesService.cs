using Models;
using Models.DTO;

namespace Services;

public interface IQuotesService
{
    public Task<ResponsePageDto<IQuote>> ReadQuotesAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize);
}
