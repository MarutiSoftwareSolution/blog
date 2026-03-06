using Blog.Core.Domain;
using Blog.Core.Interfaces;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Blog.Web.Controllers;

[Authorize(Policy = "CanManageTags")]
[Route("admin/tags")]
public class TagsController : Controller
{
    private readonly ITagRepository _tags;

    public TagsController(ITagRepository tags)
    {
        _tags = tags;
    }

    [HttpGet("")]
    public async Task<IActionResult> Index()
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var tags = await _tags.GetAllAsync(userId);
        return View(tags);
    }

    [HttpPost("create")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(string name, string slug)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            TempData["Error"] = "Name is required.";
            return RedirectToAction("Index");
        }

        if (string.IsNullOrWhiteSpace(slug))
        {
            slug = name.ToLower().Trim().Replace(" ", "-").Replace("_", "-").Replace(".", "");
        }

        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var existing = await _tags.GetBySlugAsync(slug, userId);
        if (existing != null)
        {
            TempData["Error"] = "Tag slug already exists.";
            return RedirectToAction("Index");
        }

        var tag = new Tag
        {
            Name = name,
            Slug = slug,
            AuthorId = userId
        };

        await _tags.CreateAsync(tag);
        TempData["Success"] = "Tag created.";
        return RedirectToAction("Index");
    }

    [HttpPost("delete/{id}")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(Guid id)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        await _tags.DeleteAsync(id, userId);
        TempData["Success"] = "Tag deleted.";
        return RedirectToAction("Index");
    }
}
