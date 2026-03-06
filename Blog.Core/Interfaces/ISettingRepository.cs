using Blog.Core.Domain;

namespace Blog.Core.Interfaces;

public interface ISettingRepository
{
    Task<UserSettings> GetSettingsAsync(Guid userId);
    Task SaveSettingsAsync(Guid userId, UserSettings settings);
    Task DismissOnboardingAsync(Guid userId);
    Task CompleteOnboardingTaskAsync(Guid userId, string taskId);
    
    // Legacy signatures marking for removal
    Task<string?> GetAsync(string key);
    Task<Dictionary<string, string>> GetGroupAsync(string group);
    Task SetAsync(string key, string? value, string group = "general");
    Task SetManyAsync(Dictionary<string, string?> settings, string group = "general");
    Task<bool> IsInstalledAsync();
}
