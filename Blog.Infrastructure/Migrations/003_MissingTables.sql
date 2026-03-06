-- ============================================================
-- Beacon CMS — Missing Tables Script
-- Run this in SSMS against the [blog] database
-- ============================================================

USE [blog];
GO

-- ── beacon_SchemaVersion ──────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'beacon_SchemaVersion')
BEGIN
    CREATE TABLE beacon_SchemaVersion (
        Id          INT           IDENTITY(1,1) PRIMARY KEY,
        Version     INT           NOT NULL UNIQUE,
        AppliedAt   DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
        Description NVARCHAR(500) NOT NULL
    );
    PRINT 'Created beacon_SchemaVersion';
END
GO

-- ── beacon_Comments ───────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'beacon_Comments')
BEGIN
    CREATE TABLE beacon_Comments (
        Id          INT           IDENTITY(1,1) PRIMARY KEY,
        PostId      INT           NOT NULL REFERENCES beacon_Posts(Id) ON DELETE CASCADE,
        AuthorName  NVARCHAR(200) NOT NULL,
        AuthorEmail NVARCHAR(200) NOT NULL,
        AuthorUrl   NVARCHAR(500) NULL,
        AuthorIp    NVARCHAR(50)  NULL,
        Content     NVARCHAR(MAX) NOT NULL,
        Status      NVARCHAR(50)  NOT NULL DEFAULT 'Pending',
        ParentId    INT           NULL REFERENCES beacon_Comments(Id),
        CreatedAt   DATETIME2     NOT NULL DEFAULT GETUTCDATE()
    );
    CREATE INDEX IX_beacon_Comments_PostId ON beacon_Comments(PostId);
    CREATE INDEX IX_beacon_Comments_Status ON beacon_Comments(Status);
    PRINT 'Created beacon_Comments';
END
GO

-- ── beacon_Revisions ─────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'beacon_Revisions')
BEGIN
    CREATE TABLE beacon_Revisions (
        Id         INT           IDENTITY(1,1) PRIMARY KEY,
        EntityType NVARCHAR(50)  NOT NULL,
        EntityId   INT           NOT NULL,
        Title      NVARCHAR(500) NOT NULL,
        Content    NVARCHAR(MAX) NOT NULL,
        AuthorId   INT           NOT NULL REFERENCES beacon_Users(Id) ON DELETE CASCADE,
        CreatedAt  DATETIME2     NOT NULL DEFAULT GETUTCDATE()
    );
    CREATE INDEX IX_beacon_Revisions_Entity ON beacon_Revisions(EntityType, EntityId);
    PRINT 'Created beacon_Revisions';
END
GO

PRINT 'All missing tables created successfully.';
GO
