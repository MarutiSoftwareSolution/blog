-- ============================================================
-- Beacon CMS - 001_InitialSchema.sql
-- All tables prefixed with beacon_
-- ============================================================

-- Schema version tracking
CREATE TABLE IF NOT EXISTS beacon_SchemaVersion (
    Id          INTEGER PRIMARY KEY AUTOINCREMENT,
    Version     INTEGER NOT NULL UNIQUE,
    AppliedAt   TEXT    NOT NULL DEFAULT (datetime('now')),
    Description TEXT    NOT NULL
);

-- Users
CREATE TABLE IF NOT EXISTS beacon_Users (
    Id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    Email               TEXT    NOT NULL UNIQUE COLLATE NOCASE,
    Username            TEXT    NOT NULL UNIQUE COLLATE NOCASE,
    DisplayName         TEXT    NOT NULL DEFAULT '',
    PasswordHash        TEXT    NOT NULL,
    Role                TEXT    NOT NULL DEFAULT 'Author',
    Bio                 TEXT,
    AvatarUrl           TEXT,
    Website             TEXT,
    IsActive            INTEGER NOT NULL DEFAULT 1,
    AccessFailedCount   INTEGER NOT NULL DEFAULT 0,
    LockoutEnd          TEXT,
    RefreshToken        TEXT,
    RefreshTokenExpiry  TEXT,
    CreatedAt           TEXT    NOT NULL DEFAULT (datetime('now')),
    UpdatedAt           TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_users_email    ON beacon_Users(Email);
CREATE INDEX IF NOT EXISTS idx_users_username ON beacon_Users(Username);

-- Settings
CREATE TABLE IF NOT EXISTS beacon_Settings (
    Id      INTEGER PRIMARY KEY AUTOINCREMENT,
    Key     TEXT    NOT NULL UNIQUE,
    Value   TEXT,
    Group_  TEXT    NOT NULL DEFAULT 'general'
);

CREATE INDEX IF NOT EXISTS idx_settings_key   ON beacon_Settings(Key);
CREATE INDEX IF NOT EXISTS idx_settings_group ON beacon_Settings(Group_);

-- Categories
CREATE TABLE IF NOT EXISTS beacon_Categories (
    Id          INTEGER PRIMARY KEY AUTOINCREMENT,
    Name        TEXT    NOT NULL,
    Slug        TEXT    NOT NULL UNIQUE COLLATE NOCASE,
    Description TEXT,
    ParentId    INTEGER REFERENCES beacon_Categories(Id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_categories_slug ON beacon_Categories(Slug);

-- Tags
CREATE TABLE IF NOT EXISTS beacon_Tags (
    Id   INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT    NOT NULL,
    Slug TEXT    NOT NULL UNIQUE COLLATE NOCASE
);

CREATE INDEX IF NOT EXISTS idx_tags_slug ON beacon_Tags(Slug);

-- Media
CREATE TABLE IF NOT EXISTS beacon_Media (
    Id               INTEGER PRIMARY KEY AUTOINCREMENT,
    FileName         TEXT    NOT NULL,
    OriginalFileName TEXT    NOT NULL,
    FilePath         TEXT    NOT NULL,
    Url              TEXT    NOT NULL,
    MimeType         TEXT    NOT NULL,
    FileSize         INTEGER NOT NULL DEFAULT 0,
    Width            INTEGER,
    Height           INTEGER,
    AltText          TEXT,
    Caption          TEXT,
    UploadedBy       INTEGER NOT NULL REFERENCES beacon_Users(Id) ON DELETE CASCADE,
    CreatedAt        TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_media_uploaded_by ON beacon_Media(UploadedBy);

-- Posts
CREATE TABLE IF NOT EXISTS beacon_Posts (
    Id              INTEGER PRIMARY KEY AUTOINCREMENT,
    Title           TEXT    NOT NULL,
    Slug            TEXT    NOT NULL UNIQUE COLLATE NOCASE,
    Content         TEXT    NOT NULL DEFAULT '',
    Excerpt         TEXT    NOT NULL DEFAULT '',
    AuthorId        INTEGER NOT NULL REFERENCES beacon_Users(Id) ON DELETE CASCADE,
    Status          TEXT    NOT NULL DEFAULT 'Draft',  -- Draft, Published, Scheduled, Trash
    Visibility      TEXT    NOT NULL DEFAULT 'Public', -- Public, Private, Password
    Password        TEXT,
    PublishedAt     TEXT,
    ScheduledAt     TEXT,
    ViewCount       INTEGER NOT NULL DEFAULT 0,
    FeaturedImageId INTEGER REFERENCES beacon_Media(Id) ON DELETE SET NULL,
    AllowComments   INTEGER NOT NULL DEFAULT 1,
    CreatedAt       TEXT    NOT NULL DEFAULT (datetime('now')),
    UpdatedAt       TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_posts_slug        ON beacon_Posts(Slug);
CREATE INDEX IF NOT EXISTS idx_posts_status      ON beacon_Posts(Status);
CREATE INDEX IF NOT EXISTS idx_posts_author      ON beacon_Posts(AuthorId);
CREATE INDEX IF NOT EXISTS idx_posts_published   ON beacon_Posts(PublishedAt DESC);

-- Pages
CREATE TABLE IF NOT EXISTS beacon_Pages (
    Id              INTEGER PRIMARY KEY AUTOINCREMENT,
    Title           TEXT    NOT NULL,
    Slug            TEXT    NOT NULL UNIQUE COLLATE NOCASE,
    Content         TEXT    NOT NULL DEFAULT '',
    AuthorId        INTEGER NOT NULL REFERENCES beacon_Users(Id) ON DELETE CASCADE,
    IsPublished     INTEGER NOT NULL DEFAULT 0,
    SortOrder       INTEGER NOT NULL DEFAULT 0,
    ParentId        INTEGER REFERENCES beacon_Pages(Id) ON DELETE SET NULL,
    FeaturedImageId INTEGER REFERENCES beacon_Media(Id) ON DELETE SET NULL,
    PublishedAt     TEXT,
    CreatedAt       TEXT    NOT NULL DEFAULT (datetime('now')),
    UpdatedAt       TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_pages_slug ON beacon_Pages(Slug);

-- Post-Category pivot
CREATE TABLE IF NOT EXISTS beacon_PostCategories (
    PostId     INTEGER NOT NULL REFERENCES beacon_Posts(Id) ON DELETE CASCADE,
    CategoryId INTEGER NOT NULL REFERENCES beacon_Categories(Id) ON DELETE CASCADE,
    PRIMARY KEY (PostId, CategoryId)
);

-- Post-Tag pivot
CREATE TABLE IF NOT EXISTS beacon_PostTags (
    PostId INTEGER NOT NULL REFERENCES beacon_Posts(Id) ON DELETE CASCADE,
    TagId  INTEGER NOT NULL REFERENCES beacon_Tags(Id) ON DELETE CASCADE,
    PRIMARY KEY (PostId, TagId)
);

-- Comments
CREATE TABLE IF NOT EXISTS beacon_Comments (
    Id          INTEGER PRIMARY KEY AUTOINCREMENT,
    PostId      INTEGER NOT NULL REFERENCES beacon_Posts(Id) ON DELETE CASCADE,
    AuthorName  TEXT    NOT NULL,
    AuthorEmail TEXT    NOT NULL,
    AuthorUrl   TEXT,
    AuthorIp    TEXT,
    Content     TEXT    NOT NULL,
    Status      TEXT    NOT NULL DEFAULT 'Pending', -- Pending, Approved, Spam, Trash
    ParentId    INTEGER REFERENCES beacon_Comments(Id) ON DELETE SET NULL,
    CreatedAt   TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_comments_post_id ON beacon_Comments(PostId);
CREATE INDEX IF NOT EXISTS idx_comments_status  ON beacon_Comments(Status);

-- Revisions
CREATE TABLE IF NOT EXISTS beacon_Revisions (
    Id         INTEGER PRIMARY KEY AUTOINCREMENT,
    EntityType TEXT    NOT NULL, -- Post, Page
    EntityId   INTEGER NOT NULL,
    Title      TEXT    NOT NULL,
    Content    TEXT    NOT NULL,
    AuthorId   INTEGER NOT NULL REFERENCES beacon_Users(Id) ON DELETE CASCADE,
    CreatedAt  TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_revisions_entity ON beacon_Revisions(EntityType, EntityId);

-- Audit Log
CREATE TABLE IF NOT EXISTS beacon_AuditLog (
    Id         INTEGER PRIMARY KEY AUTOINCREMENT,
    UserId     INTEGER REFERENCES beacon_Users(Id) ON DELETE SET NULL,
    UserEmail  TEXT    NOT NULL DEFAULT '',
    Action     TEXT    NOT NULL,
    EntityType TEXT    NOT NULL DEFAULT '',
    EntityId   INTEGER,
    Details    TEXT,
    IpAddress  TEXT,
    CreatedAt  TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_audit_user      ON beacon_AuditLog(UserId);
CREATE INDEX IF NOT EXISTS idx_audit_created   ON beacon_AuditLog(CreatedAt DESC);

-- Record this migration
INSERT OR IGNORE INTO beacon_SchemaVersion (Version, Description)
VALUES (1, 'Initial schema - all core tables');
