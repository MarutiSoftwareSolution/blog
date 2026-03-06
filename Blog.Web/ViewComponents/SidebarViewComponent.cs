using Blog.Core.Domain;
using Blog.Core.Interfaces;
using Blog.Web.Models;
using Microsoft.AspNetCore.Mvc;

namespace Blog.Web.ViewComponents;

public class SidebarViewComponent : ViewComponent
{
    private readonly ICategoryRepository _categories;
    private readonly ITagRepository _tags;

    public SidebarViewComponent(ICategoryRepository categories, ITagRepository tags)
    {
        _categories = categories;
        _tags = tags;
    }

    public async Task<IViewComponentResult> InvokeAsync()
    {
        var model = new SidebarViewModel
        {
            Categories = await _categories.GetAllAsync(Guid.Empty),
            Tags = await _tags.GetAllAsync(Guid.Empty)
        };
        return View(model);
    }
}
