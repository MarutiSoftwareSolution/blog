USE [blog];
GO

-- Add CreatedByUserId to track who created or invited a user
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'CreatedByUserId')
BEGIN
    ALTER TABLE Users ADD CreatedByUserId UNIQUEIDENTIFIER NULL;
    PRINT 'Added CreatedByUserId to Users table.';
END
ELSE
BEGIN
    PRINT 'CreatedByUserId already exists in Users table.';
END
GO
