-- ============================================================
-- 015: Refactor All IDs from INT to UNIQUEIDENTIFIER (GUID) - Version 4 (RECOVERY)
-- This script is designed to recover from half-migrated states.
-- It uses individual shadow tables to move data safely.
-- ============================================================

USE [blog];
GO

-- 1. Create robust mapping function
IF OBJECT_ID('dbo.ToGuidValue') IS NOT NULL DROP FUNCTION dbo.ToGuidValue;
GO
CREATE FUNCTION dbo.ToGuidValue(@InVal ANYDATA) RETURNS UNIQUEIDENTIFIER AS
BEGIN
    -- This is a dummy signature for logic, SQL doesn't support ANYDATA like this.
    -- We skip the function for a bit and use inline logic for compatibility.
    RETURN NULL; 
END
GO
-- Redefining as specific for INT
IF OBJECT_ID('dbo.IntToGuid') IS NOT NULL DROP FUNCTION dbo.IntToGuid;
GO
CREATE FUNCTION dbo.IntToGuid(@Id INT) RETURNS UNIQUEIDENTIFIER AS
BEGIN
    IF @Id IS NULL RETURN NULL;
    -- Map INT 1 -> 00000001-0000-0000-0000-000000000000 (roughly)
    RETURN CAST(CAST(@Id AS BINARY(4)) + CAST(0x000000000000000000000000 AS BINARY(12)) AS UNIQUEIDENTIFIER);
END
GO

PRINT 'Starting GUID Recovery and Refactoring (V4)...';

-- 2. Drop EVERY POSSIBLE constraint and index in the database to clear the path
PRINT 'Dropping all Foreign Keys...';
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ' DROP CONSTRAINT ' + QUOTENAME(fk.name) + ';' + CHAR(13)
FROM sys.foreign_keys fk JOIN sys.tables t ON fk.parent_object_id = t.object_id JOIN sys.schemas s ON t.schema_id = s.schema_id;
EXEC sp_executesql @sql;

PRINT 'Dropping all Primary Keys and Unique Constraints...';
SET @sql = '';
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ' DROP CONSTRAINT ' + QUOTENAME(kc.name) + ';' + CHAR(13)
FROM sys.key_constraints kc JOIN sys.tables t ON kc.parent_object_id = t.object_id JOIN sys.schemas s ON t.schema_id = s.schema_id;
EXEC sp_executesql @sql;

PRINT 'Dropping all Indexes...';
SET @sql = '';
SELECT @sql += 'DROP INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ';' + CHAR(13)
FROM sys.indexes i JOIN sys.tables t ON i.object_id = t.object_id JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE i.name IS NOT NULL AND i.is_primary_key = 0 AND i.is_unique_constraint = 0;
EXEC sp_executesql @sql;

PRINT 'Dropping all Default Constraints...';
SET @sql = '';
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ' DROP CONSTRAINT ' + QUOTENAME(dc.name) + ';' + CHAR(13)
FROM sys.default_constraints dc JOIN sys.tables t ON dc.parent_object_id = t.object_id JOIN sys.schemas s ON t.schema_id = s.schema_id;
EXEC sp_executesql @sql;

-- 3. Define the reconstruction logic for each table
-- This logic: 
-- A) Checks if column is INT. If yes, converts. 
-- B) Checks for 'NewId' or similar from previous runs and drops them.

PRINT 'Cleaning up columns from previous failed runs...';
SET @sql = '';
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ' DROP COLUMN ' + QUOTENAME(c.name) + ';' + CHAR(13)
FROM sys.columns c JOIN sys.tables t ON c.object_id = t.object_id JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE c.name LIKE 'New%' OR c.name LIKE 'Temp%';
EXEC sp_executesql @sql;

-- Helper to safely get GUID from potentially mixed types
-- Usage: CASE WHEN TYPE_NAME(COLUMN) = 'int' THEN dbo.IntToGuid(COL) ELSE COL END

-- RECONSTRUCT beacon_Users
PRINT 'Reconstructing beacon_Users...';
IF OBJECT_ID('beacon_Users_Bak') IS NOT NULL DROP TABLE beacon_Users_Bak;
SELECT 
    CASE WHEN TYPE_NAME(v.DataType) = 'int' THEN dbo.IntToGuid(CAST(v.Id AS INT)) ELSE CAST(v.Id AS UNIQUEIDENTIFIER) END as Id,
    Email, Username, DisplayName, PasswordHash, Role, Bio, AvatarUrl, Website, IsActive, CreatedAt, UpdatedAt,
    RefreshToken, RefreshTokenExpiry, LockoutEnd, AccessFailedCount
INTO beacon_Users_Bak
FROM (SELECT Id, Email, Username, DisplayName, PasswordHash, Role, Bio, AvatarUrl, Website, IsActive, CreatedAt, UpdatedAt, RefreshToken, RefreshTokenExpiry, LockoutEnd, AccessFailedCount, (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Users') AND name = 'Id') as DataType FROM beacon_Users) v;
DROP TABLE beacon_Users;
EXEC sp_rename 'beacon_Users_Bak', 'beacon_Users';
ALTER TABLE beacon_Users ALTER COLUMN Id UNIQUEIDENTIFIER NOT NULL;
GO

-- RECONSTRUCT beacon_Media
PRINT 'Reconstructing beacon_Media...';
IF OBJECT_ID('beacon_Media_Bak') IS NOT NULL DROP TABLE beacon_Media_Bak;
SELECT 
    CASE WHEN TYPE_NAME(v.IdType) = 'int' THEN dbo.IntToGuid(CAST(v.Id AS INT)) ELSE CAST(v.Id AS UNIQUEIDENTIFIER) END as Id,
    FileName, OriginalFileName, FilePath, Url, ContentType, FileSize, Width, Height, AltText, Caption,
    CASE WHEN TYPE_NAME(v.ByType) = 'int' THEN dbo.IntToGuid(CAST(v.UploadedBy AS INT)) ELSE CAST(v.UploadedBy AS UNIQUEIDENTIFIER) END as UploadedBy,
    CreatedAt
INTO beacon_Media_Bak
FROM (SELECT *, (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Media') AND name = 'Id') as IdType, (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Media') AND name = 'UploadedBy') as ByType FROM beacon_Media) v;
DROP TABLE beacon_Media;
EXEC sp_rename 'beacon_Media_Bak', 'beacon_Media';
ALTER TABLE beacon_Media ALTER COLUMN Id UNIQUEIDENTIFIER NOT NULL;
GO

-- RECONSTRUCT beacon_Posts
PRINT 'Reconstructing beacon_Posts...';
IF OBJECT_ID('beacon_Posts_Bak') IS NOT NULL DROP TABLE beacon_Posts_Bak;
SELECT 
    CASE WHEN TYPE_NAME(v.IdType) = 'int' THEN dbo.IntToGuid(CAST(v.Id AS INT)) ELSE CAST(v.Id AS UNIQUEIDENTIFIER) END as Id,
    Title, Slug, Content, Summary,
    CASE WHEN TYPE_NAME(v.AuthType) = 'int' THEN dbo.IntToGuid(CAST(v.AuthorId AS INT)) ELSE CAST(v.AuthorId AS UNIQUEIDENTIFIER) END as AuthorId,
    Status, CreatedAt, UpdatedAt, PublishedAt, ScheduledAt, ViewCount,
    CASE WHEN TYPE_NAME(v.ImgType) = 'int' THEN dbo.IntToGuid(CAST(v.FeaturedImageId AS INT)) ELSE CAST(v.FeaturedImageId AS UNIQUEIDENTIFIER) END as FeaturedImageId,
    AllowComments, Visibility, Password
INTO beacon_Posts_Bak
FROM (SELECT *, 
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Posts') AND name = 'Id') as IdType,
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Posts') AND name = 'AuthorId') as AuthType,
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Posts') AND name = 'FeaturedImageId') as ImgType
    FROM beacon_Posts) v;
DROP TABLE beacon_Posts;
EXEC sp_rename 'beacon_Posts_Bak', 'beacon_Posts';
ALTER TABLE beacon_Posts ALTER COLUMN Id UNIQUEIDENTIFIER NOT NULL;
GO

-- RECONSTRUCT beacon_Categories
PRINT 'Reconstructing beacon_Categories...';
IF OBJECT_ID('beacon_Categories_Bak') IS NOT NULL DROP TABLE beacon_Categories_Bak;
SELECT 
    CASE WHEN TYPE_NAME(v.IdType) = 'int' THEN dbo.IntToGuid(CAST(v.Id AS INT)) ELSE CAST(v.Id AS UNIQUEIDENTIFIER) END as Id,
    Name, Slug, Description,
    CASE WHEN TYPE_NAME(v.ParType) = 'int' THEN dbo.IntToGuid(CAST(v.ParentId AS INT)) ELSE CAST(v.ParentId AS UNIQUEIDENTIFIER) END as ParentId,
    CASE WHEN TYPE_NAME(v.AuthType) = 'int' THEN dbo.IntToGuid(CAST(v.AuthorId AS INT)) ELSE CAST(v.AuthorId AS UNIQUEIDENTIFIER) END as AuthorId,
    Color
INTO beacon_Categories_Bak
FROM (SELECT *, 
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Categories') AND name = 'Id') as IdType,
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Categories') AND name = 'ParentId') as ParType,
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Categories') AND name = 'AuthorId') as AuthType
    FROM beacon_Categories) v;
DROP TABLE beacon_Categories;
EXEC sp_rename 'beacon_Categories_Bak', 'beacon_Categories';
ALTER TABLE beacon_Categories ALTER COLUMN Id UNIQUEIDENTIFIER NOT NULL;
GO

-- RECONSTRUCT beacon_Tags
PRINT 'Reconstructing beacon_Tags...';
IF OBJECT_ID('beacon_Tags_Bak') IS NOT NULL DROP TABLE beacon_Tags_Bak;
SELECT 
    CASE WHEN TYPE_NAME(v.IdType) = 'int' THEN dbo.IntToGuid(CAST(v.Id AS INT)) ELSE CAST(v.Id AS UNIQUEIDENTIFIER) END as Id,
    Name, Slug,
    CASE WHEN TYPE_NAME(v.AuthType) = 'int' THEN dbo.IntToGuid(CAST(v.AuthorId AS INT)) ELSE CAST(v.AuthorId AS UNIQUEIDENTIFIER) END as AuthorId,
    Color
INTO beacon_Tags_Bak
FROM (SELECT *, 
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Tags') AND name = 'Id') as IdType,
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Tags') AND name = 'AuthorId') as AuthType
    FROM beacon_Tags) v;
DROP TABLE beacon_Tags;
EXEC sp_rename 'beacon_Tags_Bak', 'beacon_Tags';
ALTER TABLE beacon_Tags ALTER COLUMN Id UNIQUEIDENTIFIER NOT NULL;
GO

-- RECONSTRUCT beacon_Pages
PRINT 'Reconstructing beacon_Pages...';
IF OBJECT_ID('beacon_Pages_Bak') IS NOT NULL DROP TABLE beacon_Pages_Bak;
SELECT 
    CASE WHEN TYPE_NAME(v.IdType) = 'int' THEN dbo.IntToGuid(CAST(v.Id AS INT)) ELSE CAST(v.Id AS UNIQUEIDENTIFIER) END as Id,
    Title, Slug, Content,
    CASE WHEN TYPE_NAME(v.AuthType) = 'int' THEN dbo.IntToGuid(CAST(v.AuthorId AS INT)) ELSE CAST(v.AuthorId AS UNIQUEIDENTIFIER) END as AuthorId,
    AuthorName, IsPublished, CreatedAt, PublishedAt,
    CASE WHEN TYPE_NAME(v.ParType) = 'int' THEN dbo.IntToGuid(CAST(v.ParentId AS INT)) ELSE CAST(v.ParentId AS UNIQUEIDENTIFIER) END as ParentId,
    CASE WHEN TYPE_NAME(v.ImgType) = 'int' THEN dbo.IntToGuid(CAST(v.FeaturedImageId AS INT)) ELSE CAST(v.FeaturedImageId AS UNIQUEIDENTIFIER) END as FeaturedImageId
INTO beacon_Pages_Bak
FROM (SELECT *, 
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Pages') AND name = 'Id') as IdType,
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Pages') AND name = 'AuthorId') as AuthType,
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Pages') AND name = 'ParentId') as ParType,
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Pages') AND name = 'FeaturedImageId') as ImgType
    FROM beacon_Pages) v;
DROP TABLE beacon_Pages;
EXEC sp_rename 'beacon_Pages_Bak', 'beacon_Pages';
ALTER TABLE beacon_Pages ALTER COLUMN Id UNIQUEIDENTIFIER NOT NULL;
GO

-- RECONSTRUCT beacon_Comments
PRINT 'Reconstructing beacon_Comments...';
IF OBJECT_ID('beacon_Comments_Bak') IS NOT NULL DROP TABLE beacon_Comments_Bak;
SELECT 
    CASE WHEN TYPE_NAME(v.IdType) = 'int' THEN dbo.IntToGuid(CAST(v.Id AS INT)) ELSE CAST(v.Id AS UNIQUEIDENTIFIER) END as Id,
    CASE WHEN TYPE_NAME(v.PostType) = 'int' THEN dbo.IntToGuid(CAST(v.PostId AS INT)) ELSE CAST(v.PostId AS UNIQUEIDENTIFIER) END as PostId,
    AuthorName, AuthorEmail, AuthorUrl, AuthorIp, Content, Status,
    CASE WHEN TYPE_NAME(v.ParType) = 'int' THEN dbo.IntToGuid(CAST(v.ParentId AS INT)) ELSE CAST(v.ParentId AS UNIQUEIDENTIFIER) END as ParentId,
    CreatedAt
INTO beacon_Comments_Bak
FROM (SELECT *, 
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Comments') AND name = 'Id') as IdType,
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Comments') AND name = 'PostId') as PostType,
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Comments') AND name = 'ParentId') as ParType
    FROM beacon_Comments) v;
DROP TABLE beacon_Comments;
EXEC sp_rename 'beacon_Comments_Bak', 'beacon_Comments';
ALTER TABLE beacon_Comments ALTER COLUMN Id UNIQUEIDENTIFIER NOT NULL;
GO

-- RECONSTRUCT Pivot Tables
PRINT 'Reconstructing beacon_PostCategories...';
IF OBJECT_ID('beacon_PostCategories_Bak') IS NOT NULL DROP TABLE beacon_PostCategories_Bak;
SELECT 
    CASE WHEN TYPE_NAME(v.PostType) = 'int' THEN dbo.IntToGuid(CAST(v.PostId AS INT)) ELSE CAST(v.PostId AS UNIQUEIDENTIFIER) END as PostId,
    CASE WHEN TYPE_NAME(v.CatType) = 'int' THEN dbo.IntToGuid(CAST(v.CategoryId AS INT)) ELSE CAST(v.CategoryId AS UNIQUEIDENTIFIER) END as CategoryId
INTO beacon_PostCategories_Bak
FROM (SELECT *, 
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_PostCategories') AND name = 'PostId') as PostType,
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_PostCategories') AND name = 'CategoryId') as CatType
    FROM beacon_PostCategories) v;
DROP TABLE beacon_PostCategories;
EXEC sp_rename 'beacon_PostCategories_Bak', 'beacon_PostCategories';
GO

PRINT 'Reconstructing beacon_PostTags...';
IF OBJECT_ID('beacon_PostTags_Bak') IS NOT NULL DROP TABLE beacon_PostTags_Bak;
SELECT 
    CASE WHEN TYPE_NAME(v.PostType) = 'int' THEN dbo.IntToGuid(CAST(v.PostId AS INT)) ELSE CAST(v.PostId AS UNIQUEIDENTIFIER) END as PostId,
    CASE WHEN TYPE_NAME(v.TagType) = 'int' THEN dbo.IntToGuid(CAST(v.TagId AS INT)) ELSE CAST(v.TagId AS UNIQUEIDENTIFIER) END as TagId
INTO beacon_PostTags_Bak
FROM (SELECT *, 
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_PostTags') AND name = 'PostId') as PostType,
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_PostTags') AND name = 'TagId') as TagType
    FROM beacon_PostTags) v;
DROP TABLE beacon_PostTags;
EXEC sp_rename 'beacon_PostTags_Bak', 'beacon_PostTags';
GO

PRINT 'Reconstructing beacon_Settings...';
IF OBJECT_ID('beacon_Settings_Bak') IS NOT NULL DROP TABLE beacon_Settings_Bak;
SELECT 
    CASE WHEN TYPE_NAME(v.UserType) = 'int' THEN dbo.IntToGuid(CAST(v.UserId AS INT)) ELSE CAST(v.UserId AS UNIQUEIDENTIFIER) END as UserId,
    SiteName, SiteDescription, LogoUrl, FaviconUrl, IsInstalled, PostsPerPage, CategoryId, 
    ThemeName, ThemeSettingsJson, CustomCss, CustomJs, AnalyticsId, CommentsEnabled, 
    AkismetKey, SmtpHost, SmtpPort, SmtpUser, SmtpPass, SmtpFromBase, MailgunDomain, 
    MailgunKey, AzureSearchEndpoint, AzureSearchKey, AzureSearchIndex, Tagline
INTO beacon_Settings_Bak
FROM (SELECT *, 
    (SELECT TOP 1 system_type_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Settings') AND name = 'UserId') as UserType
    FROM beacon_Settings) v;
DROP TABLE beacon_Settings;
EXEC sp_rename 'beacon_Settings_Bak', 'beacon_Settings';
ALTER TABLE beacon_Settings ALTER COLUMN UserId UNIQUEIDENTIFIER NOT NULL;
GO

-- 4. Final Constraints and Re-indexing
PRINT 'Re-creating Primary Keys...';
ALTER TABLE beacon_Users ADD CONSTRAINT PK_Users PRIMARY KEY (Id);
ALTER TABLE beacon_Posts ADD CONSTRAINT PK_Posts PRIMARY KEY (Id);
ALTER TABLE beacon_Categories ADD CONSTRAINT PK_Categories PRIMARY KEY (Id);
ALTER TABLE beacon_Tags ADD CONSTRAINT PK_Tags PRIMARY KEY (Id);
ALTER TABLE beacon_Pages ADD CONSTRAINT PK_Pages PRIMARY KEY (Id);
ALTER TABLE beacon_Comments ADD CONSTRAINT PK_Comments PRIMARY KEY (Id);
ALTER TABLE beacon_Media ADD CONSTRAINT PK_Media PRIMARY KEY (Id);
ALTER TABLE beacon_PostCategories ADD CONSTRAINT PK_PostCategories PRIMARY KEY (PostId, CategoryId);
ALTER TABLE beacon_PostTags ADD CONSTRAINT PK_PostTags PRIMARY KEY (PostId, TagId);
GO

PRINT 'Re-creating Foreign Keys...';
ALTER TABLE beacon_Posts ADD CONSTRAINT FK_Posts_Author FOREIGN KEY (AuthorId) REFERENCES beacon_Users(Id);
ALTER TABLE beacon_Comments ADD CONSTRAINT FK_Comments_Post FOREIGN KEY (PostId) REFERENCES beacon_Posts(Id);
ALTER TABLE beacon_PostCategories ADD CONSTRAINT FK_PC_Post FOREIGN KEY (PostId) REFERENCES beacon_Posts(Id);
ALTER TABLE beacon_PostCategories ADD CONSTRAINT FK_PC_Cat FOREIGN KEY (CategoryId) REFERENCES beacon_Categories(Id);
ALTER TABLE beacon_PostTags ADD CONSTRAINT FK_PT_Post FOREIGN KEY (PostId) REFERENCES beacon_Posts(Id);
ALTER TABLE beacon_PostTags ADD CONSTRAINT FK_PT_Tag FOREIGN KEY (TagId) REFERENCES beacon_Tags(Id);
ALTER TABLE beacon_Settings ADD CONSTRAINT FK_Settings_User FOREIGN KEY (UserId) REFERENCES beacon_Users(Id);
GO

PRINT 'Re-creating Indexes...';
CREATE UNIQUE INDEX idx_users_email ON beacon_Users(Email);
CREATE UNIQUE INDEX idx_posts_slug ON beacon_Posts(Slug);
CREATE INDEX idx_posts_published ON beacon_Posts(PublishedAt DESC);
CREATE UNIQUE INDEX idx_categories_slug ON beacon_Categories(Slug);
CREATE UNIQUE INDEX idx_tags_slug ON beacon_Tags(Slug);
GO

PRINT 'GUID Recovery System (V4) Complete! 🚀';
GO
