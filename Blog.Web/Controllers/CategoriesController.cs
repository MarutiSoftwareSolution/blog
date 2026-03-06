using Blog.Core.Domain;
using Blog.Core.Interfaces;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Blog.Web.Controllers;

[Authorize(Policy = "CanManageCategories")]
[Route("admin/categories")]
public class CategoriesController : Controller
{
    private readonly ICategoryRepository _categories;

    public CategoriesController(ICategoryRepository categories)
    {
        _categories = categories;
    }

    [HttpGet("")]
    public async Task<IActionResult> Index()
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var categories = await _categories.GetAllAsync(userId);
        return View(categories);
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
        if (await _categories.SlugExistsAsync(slug, userId))
        {
            TempData["Error"] = "Slug already exists.";
            return RedirectToAction("Index");
        }

        var category = new Category
        {
            Name = name,
            Slug = slug,
            AuthorId = userId
        };

        await _categories.CreateAsync(category);
        TempData["Success"] = "Category created.";
        return RedirectToAction("Index");
    }

    [HttpPost("delete/{id}")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(Guid id)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        await _categories.DeleteAsync(id, userId);
        TempData["Success"] = "Category deleted.";
        return RedirectToAction("Index");
    }
}
