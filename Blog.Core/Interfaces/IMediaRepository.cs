using Blog.Core.Domain;

namespace Blog.Core.Interfaces;

public interface IMediaRepository
{
    Task<List<Media>> GetAllAsync(Guid uploadedBy, int page = 1, int pageSize = 50);
    Task<Media?> GetByIdAsync(Guid id, Guid? uploadedBy = null);
    Task<Guid> CreateAsync(Media media);
    Task DeleteAsync(Guid id, Guid? uploadedBy = null);
    Task<int> GetTotalCountAsync(Guid? uploadedBy = null);
}
