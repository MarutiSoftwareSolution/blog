using System.Text.RegularExpressions;

namespace Blog.Infrastructure.Data;

public static class SlugHelper
{
    public static string Generate(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;
        var slug = text.ToLowerInvariant();
        slug = Regex.Replace(slug, @"[^a-z0-9\s-]", "");
        slug = Regex.Replace(slug, @"\s+", "-");
        slug = Regex.Replace(slug, @"-+", "-");
        return slug.Trim('-');
    }
}
