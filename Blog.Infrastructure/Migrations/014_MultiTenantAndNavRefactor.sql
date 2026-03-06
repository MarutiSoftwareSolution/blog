-- ============================================================
-- 014: Multi-Tenant Schema and Navigation UI Refactor
-- Adds AuthorId isolation to Categories and Tags.
-- Adds IsInNav toggle to Pages.
-- Refactors Settings table to support a per-user JSON blob payload.
-- ============================================================

USE [blog];
GO

-- 1. Update beacon_Categories with AuthorId
PRINT 'Refactoring beacon_Categories...';
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'AuthorId' AND Object_ID = Object_ID('beacon_Categories'))
BEGIN
    -- We assume the original Admin User is ID 1 for trailing data
    ALTER TABLE beacon_Categories ADD AuthorId INT NOT NULL DEFAULT 1;
    
    -- Drop the default constraint after adding it to keep schema clean
    DECLARE @def_name_cat VARCHAR(100);
    SELECT @def_name_cat = name FROM sys.default_constraints WHERE parent_object_id = object_id('beacon_Categories') AND parent_column_id = columnproperty(object_id('beacon_Categories'),'AuthorId','ColumnId');
    IF @def_name_cat IS NOT NULL EXEC('ALTER TABLE beacon_Categories DROP CONSTRAINT [' + @def_name_cat + ']');

    -- Add the foreign key reference
    ALTER TABLE beacon_Categories ADD CONSTRAINT FK_Categories_Author FOREIGN KEY (AuthorId) REFERENCES beacon_Users(Id) ON DELETE CASCADE;
END
IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'Color' AND Object_ID = Object_ID('beacon_Categories'))
BEGIN
    -- Drop default constraint on Color if it exists
    DECLARE @def_name_cat_color VARCHAR(100);
    SELECT @def_name_cat_color = name FROM sys.default_constraints WHERE parent_object_id = object_id('beacon_Categories') AND parent_column_id = columnproperty(object_id('beacon_Categories'),'Color','ColumnId');
    IF @def_name_cat_color IS NOT NULL EXEC('ALTER TABLE beacon_Categories DROP CONSTRAINT [' + @def_name_cat_color + ']');

    ALTER TABLE beacon_Categories DROP COLUMN Color;
END
GO

-- 2. Update beacon_Tags with AuthorId
PRINT 'Refactoring beacon_Tags...';
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'AuthorId' AND Object_ID = Object_ID('beacon_Tags'))
BEGIN
    ALTER TABLE beacon_Tags ADD AuthorId INT NOT NULL DEFAULT 1;

    DECLARE @def_name_tag VARCHAR(100);
    SELECT @def_name_tag = name FROM sys.default_constraints WHERE parent_object_id = object_id('beacon_Tags') AND parent_column_id = columnproperty(object_id('beacon_Tags'),'AuthorId','ColumnId');
    IF @def_name_tag IS NOT NULL EXEC('ALTER TABLE beacon_Tags DROP CONSTRAINT [' + @def_name_tag + ']');

    ALTER TABLE beacon_Tags ADD CONSTRAINT FK_Tags_Author FOREIGN KEY (AuthorId) REFERENCES beacon_Users(Id) ON DELETE CASCADE;
END
IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'Color' AND Object_ID = Object_ID('beacon_Tags'))
BEGIN
    -- Drop default constraint on Color if it exists
    DECLARE @def_name_tag_color VARCHAR(100);
    SELECT @def_name_tag_color = name FROM sys.default_constraints WHERE parent_object_id = object_id('beacon_Tags') AND parent_column_id = columnproperty(object_id('beacon_Tags'),'Color','ColumnId');
    IF @def_name_tag_color IS NOT NULL EXEC('ALTER TABLE beacon_Tags DROP CONSTRAINT [' + @def_name_tag_color + ']');

    ALTER TABLE beacon_Tags DROP COLUMN Color;
END
GO

-- 3. Update beacon_Pages with IsInNav
PRINT 'Refactoring beacon_Pages...';
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'IsInNav' AND Object_ID = Object_ID('beacon_Pages'))
BEGIN
    ALTER TABLE beacon_Pages ADD IsInNav BIT NOT NULL DEFAULT 1;
    -- Note: We are keeping the default constraint here so new Pages show up in the Nav by default
END
GO

-- 4. Rebuild beacon_Settings for JSON
PRINT 'Refactoring beacon_Settings...';

-- Drop the whole table and rebuild it entirely (we do not care about old individual row data as we migrate to JSON)
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'beacon_Settings')
BEGIN
    DROP TABLE beacon_Settings;
END

CREATE TABLE beacon_Settings (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL UNIQUE, -- 1-to-1 relationship: Each user gets EXACTLY one settings row
    JsonPayload NVARCHAR(MAX) NOT NULL DEFAULT '{}',
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Settings_User FOREIGN KEY (UserId) REFERENCES beacon_Users(Id) ON DELETE CASCADE
);
GO

-- Seed initial settings data as a JSON payload for the default Admin User (Id: 1)
INSERT INTO beacon_Settings (UserId, JsonPayload)
VALUES (1, '{"SiteName": "Yash Blogs", "SiteDescription": "A modern, self-hosted multi-tenant blogging platform built with .NET", "CommentsEnabled": true, "PostsPerPage": 10}');
GO

PRINT 'Migration 014 Complete! 🎉';
GO
