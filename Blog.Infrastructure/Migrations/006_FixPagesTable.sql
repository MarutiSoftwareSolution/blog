-- ============================================================
-- Beacon CMS — Fix Missing Pages Columns
-- Run this in SSMS against the [blog] database
-- ============================================================

USE [blog];
GO

-- 1. Add AuthorId
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Pages' AND COLUMN_NAME = 'AuthorId')
BEGIN
    ALTER TABLE beacon_Pages ADD AuthorId INT NULL REFERENCES beacon_Users(Id);
    PRINT 'Added AuthorId to beacon_Pages';
END
GO

-- 2. Add IsPublished (default 1 = true)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Pages' AND COLUMN_NAME = 'IsPublished')
BEGIN
    ALTER TABLE beacon_Pages ADD IsPublished BIT NOT NULL DEFAULT 1;
    PRINT 'Added IsPublished to beacon_Pages';
END
GO
-- Note: You have 'IsInNav' in your table, but we need 'IsPublished' too for the code to work.

-- 3. Add Timestamps
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Pages' AND COLUMN_NAME = 'PublishedAt')
BEGIN
    ALTER TABLE beacon_Pages ADD PublishedAt DATETIME2 NULL;
    PRINT 'Added PublishedAt to beacon_Pages';
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Pages' AND COLUMN_NAME = 'CreatedAt')
BEGIN
    ALTER TABLE beacon_Pages ADD CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added CreatedAt to beacon_Pages';
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Pages' AND COLUMN_NAME = 'UpdatedAt')
BEGIN
    ALTER TABLE beacon_Pages ADD UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE();
    PRINT 'Added UpdatedAt to beacon_Pages';
END
GO

PRINT 'Page table fixed successfully.';
GO
