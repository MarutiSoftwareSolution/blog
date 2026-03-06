using Blog.Core.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Blog.Web.Controllers;

public class ErrorController : Controller
{
    private readonly ISettingRepository _settings;
    private readonly ITenantContext _tenantContext;

    public ErrorController(ISettingRepository settings, ITenantContext tenantContext)
    {
        _settings = settings;
        _tenantContext = tenantContext;
    }

    [Route("error/{statusCode}")]
    public async Task<IActionResult> HttpStatusCodeHandler(int statusCode)
    {
        var userId = _tenantContext.IsResolved ? _tenantContext.UserId : Guid.Empty;
        var userSettings = await _settings.GetSettingsAsync(userId);
        ViewBag.SiteName = userSettings.SiteName;
        ViewBag.Tagline = userSettings.SiteDescription;

        switch (statusCode)
        {
            case 404:
                ViewData["Title"] = "Page Not Found";
                return View("NotFound");
            default:
                ViewData["Title"] = "An Error Occurred";
                return View("GenericError");
        }
    }
}

