-- Consolidate all settings into the First Admin's record
USE [blog];
GO

DECLARE @FirstAdminId UNIQUEIDENTIFIER;
SELECT TOP 1 @FirstAdminId = Id FROM Users WHERE Role = 'Admin' ORDER BY CreatedAt ASC;

IF @FirstAdminId IS NOT NULL
BEGIN
    -- 1. Try to find the 'best' settings row (prefer the one with a SiteName set)
    DECLARE @BestJson NVARCHAR(MAX);
    
    -- Pick the most recently updated JSON that isn't the default "Blogs" name
    SELECT TOP 1 @BestJson = JsonPayload 
    FROM Settings 
    WHERE JsonPayload LIKE '%"SiteName":"%' AND JsonPayload NOT LIKE '%"SiteName":"Blogs"%'
    ORDER BY UpdatedAt DESC;

    -- If we found good settings, ensure they are in the First Admin's record
    IF @BestJson IS NOT NULL
    BEGIN
        -- Update or Insert for the First Admin
        IF EXISTS (SELECT 1 FROM Settings WHERE UserId = @FirstAdminId)
            UPDATE Settings SET JsonPayload = @BestJson, UpdatedAt = GETDATE() WHERE UserId = @FirstAdminId;
        ELSE
            INSERT INTO Settings (UserId, JsonPayload, UpdatedAt) VALUES (@FirstAdminId, @BestJson, GETDATE());

        -- 2. Delete all other settings records to prevent confusion in Self-Hosted mode
        DELETE FROM Settings WHERE UserId <> @FirstAdminId;
        
        PRINT 'Consolidated settings to First Admin: ' + CAST(@FirstAdminId AS NVARCHAR(50));
    END
    ELSE
    BEGIN
        PRINT 'No customized settings found to consolidate.';
    END
END
GO
