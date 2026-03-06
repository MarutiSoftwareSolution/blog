-- =======================================================
-- CMS SCHEMA MIGRATION 
-- (Assuming tables are already named without "beacon_" prefixes)
-- =======================================================

-- =======================================================
-- 1. MODIFY EXISTING TABLES (Adding missing fields including SEO)
-- =======================================================

-- Add new fields to Posts (Excluded: CustomExcerpt, as requested)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Posts') AND name = 'Uuid')
BEGIN
    ALTER TABLE Posts ADD 
        Uuid UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
        Lexical NVARCHAR(MAX) NULL,
        Html NVARCHAR(MAX) NULL,
        Plaintext NVARCHAR(MAX) NULL,
        Type NVARCHAR(50) NULL,
        Visibility NVARCHAR(50) NULL,
        FeatureImage NVARCHAR(1000) NULL,
        -- Core SEO fields
        MetaTitle NVARCHAR(255) NULL,
        MetaDescription NVARCHAR(MAX) NULL,
        CanonicalUrl NVARCHAR(1000) NULL,
        -- Open Graph / Facebook SEO fields
        OgImage NVARCHAR(1000) NULL,
        OgTitle NVARCHAR(255) NULL,
        OgDescription NVARCHAR(MAX) NULL,
        -- Twitter Card SEO fields
        TwitterImage NVARCHAR(1000) NULL,
        TwitterTitle NVARCHAR(255) NULL,
        TwitterDescription NVARCHAR(MAX) NULL,
        -- Code Injection
        CodeInjectionHead NVARCHAR(MAX) NULL,
        CodeInjectionFoot NVARCHAR(MAX) NULL;
END
GO

-- Add new fields to Tags (Excluded: FeatureImage, as requested)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Tags') AND name = 'Uuid')
BEGIN
    ALTER TABLE Tags ADD 
        Uuid UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
        Description NVARCHAR(MAX) NULL,
        ParentId UNIQUEIDENTIFIER NULL,
        Visibility NVARCHAR(50) NULL,
        -- Core SEO fields
        MetaTitle NVARCHAR(255) NULL,
        MetaDescription NVARCHAR(MAX) NULL,
        CanonicalUrl NVARCHAR(1000) NULL,
        -- Open Graph / Facebook SEO fields
        OgImage NVARCHAR(1000) NULL,
        OgTitle NVARCHAR(255) NULL,
        OgDescription NVARCHAR(MAX) NULL,
        -- Twitter Card SEO fields
        TwitterImage NVARCHAR(1000) NULL,
        TwitterTitle NVARCHAR(255) NULL,
        TwitterDescription NVARCHAR(MAX) NULL,
        -- Code Injection
        CodeInjectionHead NVARCHAR(MAX) NULL,
        CodeInjectionFoot NVARCHAR(MAX) NULL;
END
GO

-- Add new fields to Users (Authors)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'Uuid')
BEGIN
    ALTER TABLE Users ADD 
        Uuid UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
        Slug NVARCHAR(255) NULL,
        Status NVARCHAR(50) NULL,
        ProfileImage NVARCHAR(1000) NULL,
        CoverImage NVARCHAR(1000) NULL,
        Twitter NVARCHAR(255) NULL,
        Facebook NVARCHAR(255) NULL,
        LastLogin DATETIME2 NULL,
        -- Author SEO fields
        MetaTitle NVARCHAR(255) NULL,
        MetaDescription NVARCHAR(MAX) NULL;
END
GO

-- Add new fields to PostTags
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('PostTags') AND name = 'SortOrder')
BEGIN
    ALTER TABLE PostTags ADD 
        SortOrder INT NULL;
END
GO

-- Add new fields to Comments
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Comments') AND name = 'MemberId')
BEGIN
    ALTER TABLE Comments ADD 
        MemberId UNIQUEIDENTIFIER NULL,
        Html NVARCHAR(MAX) NULL;
END
GO

-- Add new fields to Settings
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Settings') AND name = 'Group')
BEGIN
    ALTER TABLE Settings ADD 
        [Group] NVARCHAR(100) NULL,
        [Key] NVARCHAR(255) NULL,
        [Value] NVARCHAR(MAX) NULL,
        [Type] NVARCHAR(50) NULL;
END
GO

-- =======================================================
-- 2. CREATE NEW TABLES
-- =======================================================

-- --- Staff & Permissions ---

IF OBJECT_ID('Roles', 'U') IS NULL
BEGIN
    CREATE TABLE Roles (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        Uuid UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
        Name NVARCHAR(255) NOT NULL,
        Description NVARCHAR(MAX) NULL
    );
END
GO

IF OBJECT_ID('RolesUsers', 'U') IS NULL
BEGIN
    CREATE TABLE RolesUsers (
        RoleId UNIQUEIDENTIFIER NOT NULL,
        UserId UNIQUEIDENTIFIER NOT NULL,
        PRIMARY KEY (RoleId, UserId)
    );
END
GO

IF OBJECT_ID('Permissions', 'U') IS NULL
BEGIN
    CREATE TABLE Permissions (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        Uuid UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
        Name NVARCHAR(255) NOT NULL,
        ActionType NVARCHAR(50) NOT NULL,
        ObjectType NVARCHAR(50) NOT NULL
    );
END
GO

IF OBJECT_ID('PermissionsRoles', 'U') IS NULL
BEGIN
    CREATE TABLE PermissionsRoles (
        PermissionId UNIQUEIDENTIFIER NOT NULL,
        RoleId UNIQUEIDENTIFIER NOT NULL,
        PRIMARY KEY (PermissionId, RoleId)
    );
END
GO

IF OBJECT_ID('PostsAuthors', 'U') IS NULL
BEGIN
    CREATE TABLE PostsAuthors (
        PostId UNIQUEIDENTIFIER NOT NULL,
        AuthorId UNIQUEIDENTIFIER NOT NULL,
        SortOrder INT NOT NULL DEFAULT 0,
        PRIMARY KEY (PostId, AuthorId)
    );
END
GO

-- --- Members (Readers) & Engagement ---

IF OBJECT_ID('Members', 'U') IS NULL
BEGIN
    CREATE TABLE Members (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        Uuid UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
        Email NVARCHAR(255) NOT NULL,
        Name NVARCHAR(255) NULL,
        Note NVARCHAR(MAX) NULL,
        Status NVARCHAR(50) NULL,
        Subscribed BIT NOT NULL DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        DeletedAt DATETIME2 NULL
    );
END
GO

IF OBJECT_ID('Labels', 'U') IS NULL
BEGIN
    CREATE TABLE Labels (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        Name NVARCHAR(255) NOT NULL,
        Slug NVARCHAR(255) NOT NULL
    );
END
GO

IF OBJECT_ID('MembersLabels', 'U') IS NULL
BEGIN
    CREATE TABLE MembersLabels (
        MemberId UNIQUEIDENTIFIER NOT NULL,
        LabelId UNIQUEIDENTIFIER NOT NULL,
        PRIMARY KEY (MemberId, LabelId)
    );
END
GO

-- --- Newsletters & Emailing ---

IF OBJECT_ID('Newsletters', 'U') IS NULL
BEGIN
    CREATE TABLE Newsletters (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        Name NVARCHAR(255) NOT NULL,
        Slug NVARCHAR(255) NOT NULL,
        Description NVARCHAR(MAX) NULL,
        SenderName NVARCHAR(255) NULL,
        SenderEmail NVARCHAR(255) NULL,
        SenderReplyTo NVARCHAR(255) NULL,
        Status NVARCHAR(50) NULL
    );
END
GO

IF OBJECT_ID('MembersNewsletters', 'U') IS NULL
BEGIN
    CREATE TABLE MembersNewsletters (
        MemberId UNIQUEIDENTIFIER NOT NULL,
        NewsletterId UNIQUEIDENTIFIER NOT NULL,
        Subscribed BIT NOT NULL DEFAULT 0,
        PRIMARY KEY (MemberId, NewsletterId)
    );
END
GO

IF OBJECT_ID('Emails', 'U') IS NULL
BEGIN
    CREATE TABLE Emails (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        PostId UNIQUEIDENTIFIER NOT NULL,
        NewsletterId UNIQUEIDENTIFIER NOT NULL,
        Subject NVARCHAR(MAX) NOT NULL,
        Status NVARCHAR(50) NULL,
        OpensCount INT NOT NULL DEFAULT 0,
        ClicksCount INT NOT NULL DEFAULT 0,
        SentCount INT NOT NULL DEFAULT 0
    );
END
GO

-- --- System & Infrastructure ---

IF OBJECT_ID('PostRevisions', 'U') IS NULL
BEGIN
    CREATE TABLE PostRevisions (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        PostId UNIQUEIDENTIFIER NOT NULL,
        Lexical NVARCHAR(MAX) NULL,
        Title NVARCHAR(255) NULL,
        AuthorId UNIQUEIDENTIFIER NOT NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

IF OBJECT_ID('Redirects', 'U') IS NULL
BEGIN
    CREATE TABLE Redirects (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        [From] NVARCHAR(MAX) NOT NULL,
        [To] NVARCHAR(MAX) NOT NULL
    );
END
GO

IF OBJECT_ID('Snippets', 'U') IS NULL
BEGIN
    CREATE TABLE Snippets (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        Name NVARCHAR(255) NOT NULL,
        Lexical NVARCHAR(MAX) NULL,
        CreatedBy UNIQUEIDENTIFIER NOT NULL
    );
END
GO
