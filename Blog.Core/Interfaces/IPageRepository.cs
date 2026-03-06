using Blog.Core.Domain;

namespace Blog.Core.Interfaces;

public interface IPageRepository
{
    Task<List<Page>> GetAllAsync(Guid authorId);
    Task<Page?> GetByIdAsync(Guid id, Guid authorId);
    Task<Page?> GetBySlugAsync(string slug); // Global slug fetching remains global
    Task<Guid> CreateAsync(Page page);
    Task UpdateAsync(Page page);
    Task DeleteAsync(Guid id, Guid? authorId = null);
    Task<bool> SlugExistsAsync(string slug, Guid authorId, Guid? excludeId = null);
    Task<List<Page>> GetNavPagesAsync();
}
