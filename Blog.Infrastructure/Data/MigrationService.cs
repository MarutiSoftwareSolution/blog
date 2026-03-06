using Microsoft.Extensions.Logging;

namespace Blog.Infrastructure.Data;

/// <summary>
/// MigrationService is disabled — the SQL Server LocalDB 'blog' database
/// already has all beacon_ tables created manually via SSMS.
/// </summary>
public class MigrationService
{
    private readonly DapperContext _context;
    private readonly ILogger<MigrationService> _logger;

    public MigrationService(DapperContext context, ILogger<MigrationService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task RunAsync()
    {
        _logger.LogInformation("MigrationService: Checking for schema updates...");
        try 
        {
            using var connection = _context.CreateConnection();
            // Ensure Color columns exist
            var sql = @"
                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Categories') AND name = 'Color')
                BEGIN
                    ALTER TABLE beacon_Categories ADD Color NVARCHAR(50) NULL DEFAULT '#e8f5e9' WITH VALUES;
                END

                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Tags') AND name = 'Color')
                BEGIN
                    ALTER TABLE beacon_Tags ADD Color NVARCHAR(50) NULL DEFAULT '#e3f2fd' WITH VALUES;
                END
                
                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Media') AND name = 'OriginalFileName')
                BEGIN
                    ALTER TABLE beacon_Media ADD OriginalFileName NVARCHAR(1000) NULL;
                END

                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CustomThemeSettings')
                BEGIN
                    CREATE TABLE CustomThemeSettings (
                        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
                        UserId UNIQUEIDENTIFIER NOT NULL,
                        SettingGroup NVARCHAR(100) NOT NULL DEFAULT 'general',
                        SettingKey NVARCHAR(200) NOT NULL,
                        SettingType NVARCHAR(50) NOT NULL DEFAULT 'text',
                        SettingValue NVARCHAR(MAX) NULL,
                        DefaultValue NVARCHAR(MAX) NULL,
                        Label NVARCHAR(200) NULL,
                        Description NVARCHAR(500) NULL
                    );
                END";
            
            await Dapper.SqlMapper.ExecuteAsync(connection, sql);
            _logger.LogInformation("MigrationService: Schema updates applied successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "MigrationService: Error applying schema updates.");
        }
    }
}
