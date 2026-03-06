using Blog.Core.Interfaces;
using Blog.Core.Services;
using Blog.Infrastructure;
using Blog.Infrastructure.Data;
using Blog.Web.Middleware;
using Blog.Web.Services;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.FileProviders;
using Microsoft.IdentityModel.Tokens;
using SixLabors.ImageSharp.Web.DependencyInjection;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Configure Kestrel limits globally to prevent server crashes on large uploads
builder.WebHost.ConfigureKestrel(serverOptions =>
{
    serverOptions.Limits.MaxRequestBodySize = 104 * 1024 * 1024; // 104 MB limit
});

// ── Infrastructure (DB repositories for posts, media, etc.) ──────────────────
var connStr = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=beacon.db";
builder.Services.AddInfrastructure(connStr);

// ── Core Services ─────────────────────────────────────────────────────────────
builder.Services.AddScoped<PostService>();
builder.Services.AddScoped<AuthService>();

// ── Multi-Tenancy ─────────────────────────────────────────────────────────────
builder.Services.AddScoped<TenantContext>();
builder.Services.AddScoped<ITenantContext>(sp => sp.GetRequiredService<TenantContext>());

// ── Authentication (cookie only — no DB, config-based) ────────────────────────
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, options =>
    {
        options.LoginPath = "/account/login";
        options.LogoutPath = "/account/logout";
        options.AccessDeniedPath = "/account/accessdenied";
        options.ExpireTimeSpan = TimeSpan.FromHours(8);
        options.SlidingExpiration = true;
        options.Cookie.HttpOnly = true;
        options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
        options.Cookie.SameSite = SameSiteMode.Lax;
    });

builder.Services.AddAuthorization(options =>
{
    // Role-based policies
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
    options.AddPolicy("EditorOrAbove", policy => policy.RequireRole("Admin", "Editor"));

    // Permission-based policies (claims loaded from RBAC tables at sign-in)
    options.AddPolicy("CanEditPosts", policy => policy.RequireClaim("Permission", "posts.edit"));
    options.AddPolicy("CanPublishPosts", policy => policy.RequireClaim("Permission", "posts.publish"));
    options.AddPolicy("CanDeletePosts", policy => policy.RequireClaim("Permission", "posts.delete"));
    options.AddPolicy("CanManagePages", policy => policy.RequireClaim("Permission", "pages.manage"));
    options.AddPolicy("CanManageComments", policy => policy.RequireClaim("Permission", "comments.manage"));
    options.AddPolicy("CanManageCategories", policy => policy.RequireClaim("Permission", "categories.manage"));
    options.AddPolicy("CanManageTags", policy => policy.RequireClaim("Permission", "tags.manage"));
    options.AddPolicy("CanManageMedia", policy => policy.RequireClaim("Permission", "media.manage"));
    options.AddPolicy("CanManageSettings", policy => policy.RequireClaim("Permission", "settings.manage"));
    options.AddPolicy("CanManageThemes", policy => policy.RequireClaim("Permission", "themes.manage"));
});
builder.Services.AddControllersWithViews();
builder.Services.AddMemoryCache();
builder.Services.AddRouting(options => options.LowercaseUrls = true);
builder.Services.AddImageSharp();

var oldUploads = Path.Combine(builder.Environment.ContentRootPath, "Uploads");
var newUploads = Path.Combine(builder.Environment.ContentRootPath, "wwwroot", "uploads");
if (Directory.Exists(oldUploads))
{
    try 
    {
        if (!Directory.Exists(newUploads)) Directory.CreateDirectory(newUploads);
        foreach (var dirPath in Directory.GetDirectories(oldUploads, "*", SearchOption.AllDirectories))
            Directory.CreateDirectory(dirPath.Replace(oldUploads, newUploads));
        foreach (var filePath in Directory.GetFiles(oldUploads, "*.*", SearchOption.AllDirectories))
        {
            var target = filePath.Replace(oldUploads, newUploads);
            if (!File.Exists(target)) File.Move(filePath, target);
        }
        
        // Safety cleanup explicitly requested by user
        Directory.Delete(oldUploads, true);
    } 
    catch { }
}

var app = builder.Build();

// Run migrations on startup
using (var scope = app.Services.CreateScope())
{
    try {
        var migrator = scope.ServiceProvider.GetRequiredService<MigrationService>();
        migrator.RunAsync().Wait();
    } catch (Exception ex) {
        app.Logger.LogError(ex, "Migration Error");
    }
}

// ── Pipeline ──────────────────────────────────────────────────────────────────
app.UseDeveloperExceptionPage();
app.UseStatusCodePagesWithReExecute("/error/{0}");

app.UseImageSharp(); // Intercepts image requests from wwwroot automatically!
app.UseStaticFiles(); // Core wwwroot file serving

app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.UseTenantResolution();

// ── Routes ────────────────────────────────────────────────────────────────────
// Attribute-routed controllers (admin, API)
app.MapControllers();

// Conventional routes
app.MapControllerRoute(
    name: "setup",
    pattern: "setup/{action=Index}/{id?}",
    defaults: new { controller = "Setup" });

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Account}/{action=Login}/{id?}");

app.Run();

public partial class Program { }
