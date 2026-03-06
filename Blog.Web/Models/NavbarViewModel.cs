namespace Blog.Web.Models;

public class NavbarViewModel
{
    public string SiteName { get; set; } = string.Empty;
    public string Tagline { get; set; } = string.Empty;
    public string SiteLogoUrl { get; set; } = string.Empty;
    public List<Blog.Core.Domain.Page> Pages { get; set; } = new List<Blog.Core.Domain.Page>();
    public List<Blog.Core.Domain.Category> Categories { get; set; } = new List<Blog.Core.Domain.Category>();
}
