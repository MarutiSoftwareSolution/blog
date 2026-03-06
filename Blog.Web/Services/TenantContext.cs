using Blog.Core.Interfaces;

namespace Blog.Web.Services;

/// <summary>
/// Scoped service implementing ITenantContext. 
/// Populated by TenantMiddleware early in the request pipeline.
/// </summary>
public class TenantContext : ITenantContext
{
    public Guid UserId { get; set; }
    public string Slug { get; set; } = string.Empty;
    public bool IsCloudMode { get; set; }
    public string TenantPathPrefix => IsCloudMode && !string.IsNullOrEmpty(Slug) ? $"/{Slug}" : "";
    public bool IsResolved { get; set; }
}
