using Blog.Core.Domain;

namespace Blog.Core.Interfaces;

public interface IUserRepository
{
    Task<User?> GetByIdAsync(Guid id);
    Task<User?> GetByEmailAsync(string email);
    Task<Guid> CreateAsync(User user);
    Task UpdateAsync(User user);
    Task<bool> AnyUsersExistAsync();
    Task<User?> GetBySlugAsync(string slug);
    Task<User?> GetFirstAdminAsync();
    Task<List<User>> GetAllUsersAsync();
    Task DeleteAsync(Guid id);
}
