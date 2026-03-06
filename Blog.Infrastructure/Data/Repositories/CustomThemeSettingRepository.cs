using Blog.Core.Domain;
using Blog.Core.Interfaces;
using Dapper;

namespace Blog.Infrastructure.Data.Repositories;

public class CustomThemeSettingRepository : ICustomThemeSettingRepository
{
    private readonly DapperContext _ctx;
    public CustomThemeSettingRepository(DapperContext ctx) => _ctx = ctx;

    public async Task<List<CustomThemeSetting>> GetAllAsync(Guid userId)
    {
        using var conn = _ctx.CreateConnection();
        var results = await conn.QueryAsync<CustomThemeSetting>(
            "SELECT * FROM CustomThemeSettings WHERE UserId = @UserId ORDER BY SettingGroup, SettingKey",
            new { UserId = userId });
        return results.ToList();
    }

    public async Task<CustomThemeSetting?> GetByKeyAsync(Guid userId, string key)
    {
        using var conn = _ctx.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<CustomThemeSetting>(
            "SELECT * FROM CustomThemeSettings WHERE UserId = @UserId AND SettingKey = @Key",
            new { UserId = userId, Key = key });
    }

    public async Task SaveAllAsync(Guid userId, List<CustomThemeSetting> settings)
    {
        using var conn = _ctx.CreateConnection();
        foreach (var s in settings)
        {
            // Clean checkbox values: "true,false" → "true"
            var cleanValue = s.SettingValue?.Split(',')[0]?.Trim();

            await conn.ExecuteAsync(@"
                MERGE CustomThemeSettings AS target
                USING (SELECT @UserId AS UserId, @SettingKey AS SettingKey) AS source
                ON target.UserId = source.UserId AND target.SettingKey = source.SettingKey
                WHEN MATCHED THEN UPDATE SET SettingValue = @SettingValue
                WHEN NOT MATCHED THEN INSERT (Id, UserId, SettingGroup, SettingKey, SettingType, SettingValue, DefaultValue, Label, Description)
                    VALUES (NEWID(), @UserId, @SettingGroup, @SettingKey, @SettingType, @SettingValue, @SettingValue, @Label, @Description);",
                new { UserId = userId, s.SettingKey, SettingValue = cleanValue,
                      SettingGroup = s.SettingGroup ?? "appearance", SettingType = s.SettingType ?? "boolean",
                      Label = s.Label ?? s.SettingKey, Description = s.Description ?? "" });
        }
    }

    public async Task SeedDefaultsAsync(Guid userId, List<CustomThemeSetting> defaults)
    {
        using var conn = _ctx.CreateConnection();

        // Seed each setting individually — only INSERT if not already exists
        foreach (var d in defaults)
        {
            d.UserId = userId;
            await conn.ExecuteAsync(@"
                IF NOT EXISTS (
                    SELECT 1 FROM CustomThemeSettings 
                    WHERE UserId = @UserId AND SettingKey = @SettingKey
                )
                INSERT INTO CustomThemeSettings 
                    (Id, UserId, SettingGroup, SettingKey, SettingType, SettingValue, DefaultValue, Label, Description)
                VALUES 
                    (@Id, @UserId, @SettingGroup, @SettingKey, @SettingType, @DefaultValue, @DefaultValue, @Label, @Description)",
                d);
        }
    }
}
