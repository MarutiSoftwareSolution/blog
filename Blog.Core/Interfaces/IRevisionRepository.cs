using Blog.Core.Domain;

namespace Blog.Core.Interfaces;

public interface IRevisionRepository
{
    Task<List<Revision>> GetByEntityAsync(string entityType, Guid entityId);
    Task<Revision?> GetByIdAsync(Guid id);
    Task<Guid> CreateAsync(Revision revision);
    Task DeleteAsync(Guid id);
}
