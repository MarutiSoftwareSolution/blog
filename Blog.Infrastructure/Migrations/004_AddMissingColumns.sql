-- ============================================================
-- Beacon CMS — Key Fixes for Missing Columns
-- Run this in SSMS against the [blog] database
-- ============================================================

USE [blog];
GO

-- 1. Fix beacon_Media (Add Url if missing)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Media' AND COLUMN_NAME = 'Url')
BEGIN
    ALTER TABLE beacon_Media ADD Url NVARCHAR(MAX) NOT NULL DEFAULT '';
    PRINT 'Added Url to beacon_Media';
END
GO

-- 2. Fix beacon_Posts (Add FeaturedImageId if missing)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Posts' AND COLUMN_NAME = 'FeaturedImageId')
BEGIN
    ALTER TABLE beacon_Posts ADD FeaturedImageId INT NULL REFERENCES beacon_Media(Id);
    PRINT 'Added FeaturedImageId to beacon_Posts';
END
GO

-- 3. Fix beacon_Pages (Add FeaturedImageId if missing)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Pages' AND COLUMN_NAME = 'FeaturedImageId')
BEGIN
    ALTER TABLE beacon_Pages ADD FeaturedImageId INT NULL REFERENCES beacon_Media(Id);
    PRINT 'Added FeaturedImageId to beacon_Pages';
END
GO

PRINT 'Database patched successfully.';
GO
