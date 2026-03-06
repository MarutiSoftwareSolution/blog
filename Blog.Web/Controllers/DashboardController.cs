using Blog.Core.Interfaces;
using Blog.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Blog.Web.Controllers;

[Authorize]
[Route("admin/[controller]")]
public class DashboardController : Controller
{
    private readonly IPostRepository _posts;
    private readonly ICommentRepository _comments;
    private readonly ISettingRepository _settings;
    private readonly IUserRepository _users;
    private readonly IMediaRepository _media;
    private readonly ApplicationDbSeeder _seeder;

    public DashboardController(
        IPostRepository posts,
        ICommentRepository comments,
        ISettingRepository settings,
        IUserRepository users,
        IMediaRepository media,
        ApplicationDbSeeder seeder)
    {
        _posts = posts;
        _comments = comments;
        _settings = settings;
        _users = users;
        _media = media;
        _seeder = seeder;
    }

    private Guid GetCurrentUserId()
    {
        var raw = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return Guid.TryParse(raw, out var id) ? id : Guid.Empty;
    }

    [HttpGet("")]
    public async Task<IActionResult> Index()
    {
        var userId = GetCurrentUserId();

        ViewBag.TotalPosts = await _posts.GetTotalCountAsync(null, userId);
        ViewBag.PublishedPosts = await _posts.GetTotalCountAsync(Blog.Core.Domain.PostStatus.Published, userId);
        ViewBag.DraftPosts = await _posts.GetTotalCountAsync(Blog.Core.Domain.PostStatus.Draft, userId);
        ViewBag.PendingComments = await _comments.GetPendingCountAsync();
        ViewBag.RecentPosts = await _posts.GetRecentPostsAsync(5, userId);
        
        var userSettings = await _settings.GetSettingsAsync(userId);
        ViewBag.SiteName = userSettings?.SiteName;

        // ── Onboarding state ────────────────────────────────────────────────
        if (userSettings != null && !userSettings.OnboardingDismissed)
        {
            var completedTasks = new HashSet<string>(userSettings.OnboardingCompletedTasks ?? new List<string>());

            // Auto-detect from real data
            if (userSettings.SiteName != "Blogs" && !string.IsNullOrWhiteSpace(userSettings.SiteName))
                completedTasks.Add("name_your_blog");

            if (ViewBag.TotalPosts is int tPosts && tPosts > 0)
                completedTasks.Add("write_first_post");

            var currentUser = await _users.GetByIdAsync(userId);
            if (currentUser != null && (!string.IsNullOrWhiteSpace(currentUser.Bio) || !string.IsNullOrWhiteSpace(currentUser.AvatarUrl) || !string.IsNullOrWhiteSpace(currentUser.ProfileImage) || !string.IsNullOrWhiteSpace(currentUser.Website) || !string.IsNullOrWhiteSpace(currentUser.Twitter)))
                completedTasks.Add("update_profile");

            if ((int)ViewBag.TotalPosts > 0)
                completedTasks.Add("explore_editor");

            // Auto-detect media presence
            int totalMedia = await _media.GetTotalCountAsync(userId);
            if (totalMedia > 0)
                completedTasks.Add("upload_cover");

            // Auto-detect settings changes
            if (!userSettings.CommentsEnabled || userSettings.CommentsModeration || userSettings.SiteDescription != "A modern, self-hosted multi-tenant blogging platform built with .NET")
                completedTasks.Add("configure_settings");

            if (completedTasks.Count >= 6)
            {
                userSettings.OnboardingDismissed = true;
                await _settings.SaveSettingsAsync(userId, userSettings);
                ViewBag.ShowOnboarding = false;
            }
            else
            {
                ViewBag.ShowOnboarding = true;
                ViewBag.OnboardingCompleted = completedTasks;
            }
        }
        else
        {
            ViewBag.ShowOnboarding = false;
            ViewBag.OnboardingCompleted = new HashSet<string>();
        }
        // ────────────────────────────────────────────────────────────────────

        return View();
    }

    // ── Onboarding AJAX endpoints ────────────────────────────────────────────

    [HttpPost("onboarding/dismiss")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> DismissOnboarding()
    {
        await _settings.DismissOnboardingAsync(GetCurrentUserId());
        return Ok(new { success = true });
    }

    [HttpPost("onboarding/complete-task")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> CompleteOnboardingTask([FromForm] string taskId)
    {
        if (string.IsNullOrWhiteSpace(taskId))
            return BadRequest(new { success = false, error = "taskId is required" });

        await _settings.CompleteOnboardingTaskAsync(GetCurrentUserId(), taskId);
        return Ok(new { success = true });
    }

    // ── Manual Seed Endpoint ─────────────────────────────────────────────────

    [HttpGet("seed")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<IActionResult> Seed()
    {
        try
        {
            await _seeder.SeedAsync();
            TempData["Success"] = "Database seeded successfully! 🌱";
        }
        catch (Exception ex)
        {
            TempData["Error"] = $"Seed failed: {ex.Message}";
        }
        return RedirectToAction("Index");
    }
}
