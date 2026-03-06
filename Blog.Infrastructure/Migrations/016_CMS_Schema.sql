-- =======================================================
-- 1. RENAME EXISTING TABLES (Remove "beacon_" prefix)
-- =======================================================
EXEC sp_rename 'beacon_Categories', 'Categories';
EXEC sp_rename 'beacon_Comments', 'Comments';
EXEC sp_rename 'beacon_Media', 'Media';
EXEC sp_rename 'beacon_Pages', 'Pages';
EXEC sp_rename 'beacon_PostCategories', 'PostCategories';
EXEC sp_rename 'beacon_Posts', 'Posts';
EXEC sp_rename 'beacon_PostTags', 'PostTags';
EXEC sp_rename 'beacon_Settings', 'Settings';
EXEC sp_rename 'beacon_Tags', 'Tags';
EXEC sp_rename 'beacon_Users', 'Users';
GO

-- =======================================================
-- 2. MODIFY EXISTING TABLES (Adding missing fields including SEO)
-- =======================================================

-- Add new fields to Posts (Excluded: CustomExcerpt, as requested)
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

-- Add new fields to Tags (Excluded: FeatureImage, as requested)
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

-- Add new fields to Users (Authors)
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

-- Add new fields to PostTags
ALTER TABLE PostTags ADD 
    SortOrder INT NULL;

-- Add new fields to Comments
ALTER TABLE Comments ADD 
    MemberId UNIQUEIDENTIFIER NULL,
    Html NVARCHAR(MAX) NULL;

-- Add new fields to Settings
ALTER TABLE Settings ADD 
    [Group] NVARCHAR(100) NULL,
    [Key] NVARCHAR(255) NULL,
    [Value] NVARCHAR(MAX) NULL,
    [Type] NVARCHAR(50) NULL;
GO

-- =======================================================
-- 3. CREATE NEW TABLES
-- =======================================================

-- --- Staff & Permissions ---

CREATE TABLE Roles (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Uuid UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX) NULL
);

CREATE TABLE RolesUsers (
    RoleId UNIQUEIDENTIFIER NOT NULL,
    UserId UNIQUEIDENTIFIER NOT NULL,
    PRIMARY KEY (RoleId, UserId)
);

CREATE TABLE Permissions (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Uuid UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    ActionType NVARCHAR(50) NOT NULL,
    ObjectType NVARCHAR(50) NOT NULL
);

CREATE TABLE PermissionsRoles (
    PermissionId UNIQUEIDENTIFIER NOT NULL,
    RoleId UNIQUEIDENTIFIER NOT NULL,
    PRIMARY KEY (PermissionId, RoleId)
);

CREATE TABLE PostsAuthors (
    PostId UNIQUEIDENTIFIER NOT NULL,
    AuthorId UNIQUEIDENTIFIER NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    PRIMARY KEY (PostId, AuthorId)
);

-- --- Members (Readers) & Engagement ---

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

CREATE TABLE Labels (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(255) NOT NULL,
    Slug NVARCHAR(255) NOT NULL
);

CREATE TABLE MembersLabels (
    MemberId UNIQUEIDENTIFIER NOT NULL,
    LabelId UNIQUEIDENTIFIER NOT NULL,
    PRIMARY KEY (MemberId, LabelId)
);

-- --- Newsletters & Emailing ---

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

CREATE TABLE MembersNewsletters (
    MemberId UNIQUEIDENTIFIER NOT NULL,
    NewsletterId UNIQUEIDENTIFIER NOT NULL,
    Subscribed BIT NOT NULL DEFAULT 0,
    PRIMARY KEY (MemberId, NewsletterId)
);

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

-- --- System & Infrastructure ---

CREATE TABLE PostRevisions (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    PostId UNIQUEIDENTIFIER NOT NULL,
    Lexical NVARCHAR(MAX) NULL,
    Title NVARCHAR(255) NULL,
    AuthorId UNIQUEIDENTIFIER NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE Redirects (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [From] NVARCHAR(MAX) NOT NULL,
    [To] NVARCHAR(MAX) NOT NULL
);

CREATE TABLE Snippets (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(255) NOT NULL,
    Lexical NVARCHAR(MAX) NULL,
    CreatedBy UNIQUEIDENTIFIER NOT NULL
);
GO
