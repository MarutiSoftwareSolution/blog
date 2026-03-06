-- Migrate Settings from the User's ID to the Guid.Empty row
USE [blog];
GO

DECLARE @AdminId UNIQUEIDENTIFIER;
SELECT TOP 1 @AdminId = Id FROM Users WHERE Role = 'Admin' ORDER BY CreatedAt ASC;

IF @AdminId IS NOT NULL
BEGIN
    DECLARE @AdminJson NVARCHAR(MAX);
    SELECT @AdminJson = JsonPayload FROM Settings WHERE UserId = @AdminId AND UserId <> '00000000-0000-0000-0000-000000000000';

    IF @AdminJson IS NOT NULL
    BEGIN
        -- Update the main Guid.Empty settings row with the Admin's settings
        UPDATE Settings 
        SET JsonPayload = @AdminJson, UpdatedAt = GETDATE()
        WHERE UserId = '00000000-0000-0000-0000-000000000000';
        
        PRINT 'Migrated Admin settings to Guid.Empty';
    END
    ELSE
    BEGIN
        PRINT 'No unique Admin settings found to migrate.';
    END
END
GO
