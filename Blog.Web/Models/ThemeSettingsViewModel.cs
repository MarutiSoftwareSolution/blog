using Blog.Core.Domain;
using System.ComponentModel.DataAnnotations;

namespace Blog.Web.Models;

public class ThemeSettingsViewModel
{
    public List<CustomThemeSetting> Settings { get; set; } = new();

    /// <summary>
    /// Group settings by their SettingGroup for rendering in the UI.
    /// </summary>
    public Dictionary<string, List<CustomThemeSetting>> GroupedSettings =>
        Settings
            .GroupBy(s => s.SettingGroup)
            .OrderBy(g => g.Key == "colors" ? 0 : g.Key == "typography" ? 1 : g.Key == "layout" ? 2 : 3)
            .ToDictionary(g => g.Key, g => g.ToList());
}
