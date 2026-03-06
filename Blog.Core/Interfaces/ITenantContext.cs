namespace Blog.Core.Interfaces;

/// <summary>
/// Provides the resolved tenant identity for the current request.
/// In self-hosted mode: always the single admin user.
/// In cloud mode: resolved from the URL path /{username}/...
/// </summary>
public interface ITenantContext
{
    /// <summary>Resolved tenant user ID (Guid.Empty if not yet resolved).</summary>
    Guid UserId { get; }

    /// <summary>Tenant's URL slug (username). Empty in self-hosted mode.</summary>
    string Slug { get; }

    /// <summary>True when running in cloud/SaaS multi-tenant mode.</summary>
    bool IsCloudMode { get; }

    /// <summary>
    /// URL path prefix for the tenant: "/{slug}" in cloud mode, "" in self-hosted.
    /// Use this when generating links in views.
    /// </summary>
    string TenantPathPrefix { get; }

    /// <summary>Whether the tenant was successfully resolved for this request.</summary>
    bool IsResolved { get; }
}
