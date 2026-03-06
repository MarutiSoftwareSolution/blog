using Blog.Core.Domain;

namespace Blog.Web.Models;

public class SidebarViewModel
{
    public List<Category> Categories { get; set; } = new();
    public List<Tag> Tags { get; set; } = new();
}
