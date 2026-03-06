using Blog.Core.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Blog.Web.ViewComponents;

public class FooterViewComponent : ViewComponent
{
    private readonly ICustomThemeSettingRepository _themeSettings;

    public FooterViewComponent(ICustomThemeSettingRepository themeSettings)
    {
        _themeSettings = themeSettings;
    }

    public async Task<IViewComponentResult> InvokeAsync(Guid ownerId)
    {
        var layoutSetting = await _themeSettings.GetByKeyAsync(ownerId, "layout-footer");
        var layout = layoutSetting?.EffectiveValue ?? "Neutral";

        ViewBag.OwnerId = ownerId;
        return View(layout);
    }
}
