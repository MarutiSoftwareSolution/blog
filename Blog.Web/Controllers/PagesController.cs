using Blog.Core.Domain;
using Blog.Core.Interfaces;
using Blog.Infrastructure.Data; // For SlugHelper
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Blog.Web.Controllers;

[Authorize(Policy = "CanManagePages")]
[Route("admin/[controller]")]
public class PagesController : Controller
{
    // ... (rest as before)
    private readonly IPageRepository _pages;
    private readonly IMediaRepository _media;
    private readonly IUserRepository _users;

    public PagesController(IPageRepository pages, IMediaRepository media, IUserRepository users)
    {
        _pages = pages;
        _media = media;
        _users = users;
    }

    [HttpGet("")]
    public async Task<IActionResult> Index()
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var pages = await _pages.GetAllAsync(userId);
        return View(pages);
    }

    [HttpGet("create")]
    public IActionResult Create()
    {
        return View(new Page { IsPublished = true });
    }

    [HttpPost("create")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(Page page, string action)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out var userId))
        {
            await HttpContext.SignOutAsync(Microsoft.AspNetCore.Authentication.Cookies.CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("Login", "Account");
        }

        // Title is required
        if (string.IsNullOrWhiteSpace(page.Title))
        {
            TempData["Error"] = "Title is required.";
            return View(page);
        }

        try
        {
            page.AuthorId = userId;
            if (action == "publish") page.IsPublished = true;
            else if (action == "draft") page.IsPublished = false;

            // Auto-generate slug if empty
            if (string.IsNullOrWhiteSpace(page.Slug))
                page.Slug = SlugHelper.Generate(page.Title);

            if (await _pages.SlugExistsAsync(page.Slug, userId))
            {
                TempData["Error"] = "A page with this URL slug already exists. Please use a different slug.";
                return View(page);
            }

            page.PublishedAt = page.IsPublished ? DateTime.UtcNow : null;
            
            var id = await _pages.CreateAsync(page);
            TempData["Success"] = page.IsPublished ? "Page published!" : "Draft saved.";
            return RedirectToAction("Edit", new { id });
        }
        catch (Exception ex)
        {
            TempData["Error"] = $"Failed to create page: {ex.Message}";
            return View(page);
        }
    }

    [HttpGet("edit/{id}")]
    public async Task<IActionResult> Edit(Guid id)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var page = await _pages.GetByIdAsync(id, userId);
        if (page == null) return NotFound();
        return View(page);
    }

    [HttpPost("edit/{id}")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(Guid id, Page page, string action)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out var userId))
        {
            await HttpContext.SignOutAsync(Microsoft.AspNetCore.Authentication.Cookies.CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("Login", "Account");
        }

        if (string.IsNullOrWhiteSpace(page.Title))
        {
            TempData["Error"] = "Title is required.";
            return View(page);
        }

        try
        {
            var existing = await _pages.GetByIdAsync(id, userId);
            if (existing == null) return NotFound();

            existing.Title = page.Title;
            existing.Slug = page.Slug;
            existing.Content = page.Content;
            existing.FeaturedImageId = page.FeaturedImageId;
            existing.ParentId = page.ParentId;
            existing.SortOrder = page.SortOrder;

            if (action == "publish")
            {
                existing.IsPublished = true;
                if (existing.PublishedAt == null) existing.PublishedAt = DateTime.UtcNow;
            }
            else if (action == "draft")
            {
                existing.IsPublished = false;
            }

            if (await _pages.SlugExistsAsync(existing.Slug, userId, id))
            {
                TempData["Error"] = "A page with this URL slug already exists. Please use a different slug.";
                return View(page);
            }

            await _pages.UpdateAsync(existing);
            TempData["Success"] = "Page updated.";
            return RedirectToAction("Edit", new { id });
        }
        catch (Exception ex)
        {
            TempData["Error"] = $"Failed to update page: {ex.Message}";
            return View(page);
        }
    }

    [HttpPost("delete/{id}")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(Guid id)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        bool isAdmin = User.IsInRole("Admin");

        await _pages.DeleteAsync(id, isAdmin ? null : userId);
        TempData["Success"] = "Page permanently deleted.";
        return RedirectToAction("Index");
    }
}


