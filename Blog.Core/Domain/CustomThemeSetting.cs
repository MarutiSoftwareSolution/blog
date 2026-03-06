namespace Blog.Core.Domain;

public class CustomThemeSetting
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public string SettingGroup { get; set; } = "general";
    public string SettingKey { get; set; } = string.Empty;
    public string SettingType { get; set; } = "text"; // color, select, image, boolean, text
    public string? SettingValue { get; set; }
    public string? DefaultValue { get; set; }
    public string? Label { get; set; }
    public string? Description { get; set; }

    /// <summary>
    /// Returns the effective value (user value or default fallback).
    /// </summary>
    public string EffectiveValue => SettingValue ?? DefaultValue ?? string.Empty;
}
