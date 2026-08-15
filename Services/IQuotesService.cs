using Models;
using Models.DTO;

namespace Services;

public interface IQuotesService
{
    public Task<ResponsePageDto<IQuote>> ReadQuotesAsync(bool seeded, bool flat, string filter, int pageNumber, int pageSize);
    public Task<ResponseItemDto<IQuote>> ReadQuoteAsync(Guid id, bool flat);
    public Task<ResponseItemDto<IQuote>> DeleteQuoteAsync(Guid id);
    public Task<ResponseItemDto<IQuote>> UpdateQuoteAsync(QuoteCuDto item);
    public Task<ResponseItemDto<IQuote>> CreateQuoteAsync(QuoteCuDto item);
}
