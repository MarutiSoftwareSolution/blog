-- ============================================================
-- Beacon CMS — Fix Missing Posts Columns
-- Run this in SSMS against the [blog] database
-- ============================================================

USE [blog];
GO

-- 1. Add Summary (formerly Excerpt)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Posts' AND COLUMN_NAME = 'Summary')
BEGIN
    ALTER TABLE beacon_Posts ADD Summary NVARCHAR(MAX) NULL;
    PRINT 'Added Summary to beacon_Posts';
END
GO
-- Note: If you already ran a script adding 'Excerpt', you can rename it or just ignore it. 
-- The code will now use 'Summary'.

-- 2. Add Visibility (Default 'Public')
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Posts' AND COLUMN_NAME = 'Visibility')
BEGIN
    ALTER TABLE beacon_Posts ADD Visibility NVARCHAR(50) NOT NULL DEFAULT 'Public';
    PRINT 'Added Visibility to beacon_Posts';
END
GO

-- 3. Add Password
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Posts' AND COLUMN_NAME = 'Password')
BEGIN
    ALTER TABLE beacon_Posts ADD Password NVARCHAR(MAX) NULL;
    PRINT 'Added Password to beacon_Posts';
END
GO

-- 4. Add ScheduledAt
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Posts' AND COLUMN_NAME = 'ScheduledAt')
BEGIN
    ALTER TABLE beacon_Posts ADD ScheduledAt DATETIME2 NULL;
    PRINT 'Added ScheduledAt to beacon_Posts';
END
GO

-- 5. Add AllowComments (Default 1)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Posts' AND COLUMN_NAME = 'AllowComments')
BEGIN
    ALTER TABLE beacon_Posts ADD AllowComments BIT NOT NULL DEFAULT 1;
    PRINT 'Added AllowComments to beacon_Posts';
END
GO

PRINT 'Posts table fixed successfully.';
GO
