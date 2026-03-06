using Blog.Core.Domain;
using Blog.Core.Interfaces;
using Blog.Core.Services;
using Microsoft.AspNetCore.Mvc;

namespace Blog.Web.Controllers;

public class SetupController : Controller
{
    private readonly ISettingRepository _settings;
    private readonly IUserRepository _users;
    private readonly AuthService _auth;

    public SetupController(ISettingRepository settings, IUserRepository users, AuthService auth)
    {
        _settings = settings;
        _users = users;
        _auth = auth;
    }

    private async Task<IActionResult> GuardAsync()
    {
        if (await _settings.IsInstalledAsync())
            return RedirectToAction("Index", "Dashboard", new { area = "" });
        return null!;
    }

    public async Task<IActionResult> Index()
    {
        var guard = await GuardAsync();
        if (guard != null) return guard;
        return View();
    }

    [HttpGet]
    public async Task<IActionResult> Step2()
    {
        var guard = await GuardAsync();
        if (guard != null) return guard;
        return View();
    }

    [HttpGet]
    public async Task<IActionResult> Step3()
    {
        var guard = await GuardAsync();
        if (guard != null) return guard;
        return View();
    }

    [HttpGet]
    public async Task<IActionResult> Review()
    {
        var guard = await GuardAsync();
        if (guard != null) return guard;
        var blogName = TempData.Peek("BlogName")?.ToString() ?? "(not set)";
        var email = TempData.Peek("AdminEmail")?.ToString() ?? "(not set)";
        ViewBag.BlogName = blogName;
        ViewBag.AdminEmail = email;
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> SaveStep2(string blogName, string tagline)
    {
        if (string.IsNullOrWhiteSpace(blogName))
        {
            ModelState.AddModelError("", "Blog name is required.");
            return View("Step2");
        }
        TempData["BlogName"] = blogName;
        TempData["Tagline"] = tagline;
        return RedirectToAction("Step3");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> SaveStep3(string email, string password, string confirmPassword)
    {
        if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
        {
            ModelState.AddModelError("", "Email and password are required.");
            return View("Step3");
        }
        if (password != confirmPassword)
        {
            ModelState.AddModelError("", "Passwords do not match.");
            return View("Step3");
        }
        if (password.Length < 8)
        {
            ModelState.AddModelError("", "Password must be at least 8 characters.");
            return View("Step3");
        }
        TempData["AdminEmail"] = email;
        TempData["AdminPassword"] = password;
        return RedirectToAction("Review");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Launch()
    {
        var blogName = TempData["BlogName"]?.ToString();
        var tagline = TempData["Tagline"]?.ToString() ?? "";
        var email = TempData["AdminEmail"]?.ToString();
        var password = TempData["AdminPassword"]?.ToString();

        if (string.IsNullOrWhiteSpace(blogName) || string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
            return RedirectToAction("Index");

        // Create admin user
        var user = new User
        {
            Email = email,
            Username = "admin",
            DisplayName = "Administrator",
            PasswordHash = _auth.HashPassword(password),
            Role = "Admin",
            IsActive = true
        };
        var userId = await _users.CreateAsync(user);

        // Save settings using the new repository method
        var settings = new UserSettings
        {
            UserId = userId,
            SiteName = blogName,
            SiteDescription = tagline,
            PostsPerPage = 20,
            CommentsEnabled = true,
            CommentsModeration = true
        };
        
        await _settings.SaveSettingsAsync(userId, settings);

        // Also save a global settings row (UserId = Guid.Empty) for public view consistency
        await _settings.SaveSettingsAsync(Guid.Empty, settings);

        return RedirectToAction("Complete");
    }

    public IActionResult Complete() => View();
}
