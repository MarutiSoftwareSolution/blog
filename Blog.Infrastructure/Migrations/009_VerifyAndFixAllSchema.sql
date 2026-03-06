-- ============================================================
-- Beacon CMS — Master Schema Verification & Fix
-- Run this in SSMS against the [blog] database
-- This script ensures ALL required columns exist.
-- ============================================================

USE [blog];
GO

-- 1. FIX [beacon_Users]
PRINT 'Checking beacon_Users...';
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Users' AND COLUMN_NAME='RefreshToken')
    ALTER TABLE beacon_Users ADD RefreshToken NVARCHAR(255) NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Users' AND COLUMN_NAME='RefreshTokenExpiry')
    ALTER TABLE beacon_Users ADD RefreshTokenExpiry DATETIME2 NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Users' AND COLUMN_NAME='AccessFailedCount')
    ALTER TABLE beacon_Users ADD AccessFailedCount INT NOT NULL DEFAULT 0;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Users' AND COLUMN_NAME='LockoutEnd')
    ALTER TABLE beacon_Users ADD LockoutEnd DATETIME2 NULL;
GO

-- 2. FIX [beacon_Categories]
PRINT 'Checking beacon_Categories...';
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Categories' AND COLUMN_NAME='ParentId')
    ALTER TABLE beacon_Categories ADD ParentId INT NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Categories' AND COLUMN_NAME='Description')
    ALTER TABLE beacon_Categories ADD Description NVARCHAR(MAX) NULL;
GO

-- 3. FIX [beacon_Comments]
PRINT 'Checking beacon_Comments...';
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Comments' AND COLUMN_NAME='AuthorUrl')
    ALTER TABLE beacon_Comments ADD AuthorUrl NVARCHAR(255) NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Comments' AND COLUMN_NAME='AuthorIp')
    ALTER TABLE beacon_Comments ADD AuthorIp NVARCHAR(45) NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Comments' AND COLUMN_NAME='ParentId')
    ALTER TABLE beacon_Comments ADD ParentId INT NULL;
GO

-- 4. FIX [beacon_Media]
PRINT 'Checking beacon_Media...';
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Media' AND COLUMN_NAME='OriginalFileName')
    ALTER TABLE beacon_Media ADD OriginalFileName NVARCHAR(255) NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Media' AND COLUMN_NAME='FileSize')
    ALTER TABLE beacon_Media ADD FileSize BIGINT NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Media' AND COLUMN_NAME='Width')
    ALTER TABLE beacon_Media ADD Width INT NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Media' AND COLUMN_NAME='Height')
    ALTER TABLE beacon_Media ADD Height INT NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Media' AND COLUMN_NAME='AltText')
    ALTER TABLE beacon_Media ADD AltText NVARCHAR(MAX) NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Media' AND COLUMN_NAME='Caption')
    ALTER TABLE beacon_Media ADD Caption NVARCHAR(MAX) NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Media' AND COLUMN_NAME='UploadedBy')
    ALTER TABLE beacon_Media ADD UploadedBy INT NULL;
GO

-- 5. FIX [beacon_Pages]
PRINT 'Checking beacon_Pages...';
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Pages' AND COLUMN_NAME='SortOrder')
    ALTER TABLE beacon_Pages ADD SortOrder INT NOT NULL DEFAULT 0;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Pages' AND COLUMN_NAME='ParentId')
    ALTER TABLE beacon_Pages ADD ParentId INT NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Pages' AND COLUMN_NAME='FeaturedImageId')
    ALTER TABLE beacon_Pages ADD FeaturedImageId INT NULL;
GO

-- 6. FIX [beacon_Settings]
PRINT 'Checking beacon_Settings...';
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='beacon_Settings' AND COLUMN_NAME='Group_')
    ALTER TABLE beacon_Settings ADD Group_ NVARCHAR(50) NULL DEFAULT 'general';
GO

-- 7. Ensure Join Tables Exist
PRINT 'Checking join tables...';
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'beacon_PostCategories')
BEGIN
    CREATE TABLE beacon_PostCategories (
        PostId INT NOT NULL,
        CategoryId INT NOT NULL,
        PRIMARY KEY (PostId, CategoryId)
    );
    PRINT 'Created beacon_PostCategories';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'beacon_PostTags')
BEGIN
    CREATE TABLE beacon_PostTags (
        PostId INT NOT NULL,
        TagId INT NOT NULL,
        PRIMARY KEY (PostId, TagId)
    );
    PRINT 'Created beacon_PostTags';
END
GO
-- Note: beacon_AuditLogs was fixed in 008, assuming it is plural now.

PRINT 'ALL SCHEMA FIXES COMPLETE! 🎉';
GO
