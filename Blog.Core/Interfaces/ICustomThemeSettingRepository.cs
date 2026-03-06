using Blog.Core.Domain;

namespace Blog.Core.Interfaces;

public interface ICustomThemeSettingRepository
{
    Task<List<CustomThemeSetting>> GetAllAsync(Guid userId);
    Task<CustomThemeSetting?> GetByKeyAsync(Guid userId, string key);
    Task SaveAllAsync(Guid userId, List<CustomThemeSetting> settings);
    Task SeedDefaultsAsync(Guid userId, List<CustomThemeSetting> defaults);
}
