-- ============================================================
-- Beacon CMS — Fix Missing Users Columns
-- Run this in SSMS against the [blog] database
-- ============================================================

USE [blog];
GO

-- Add missing columns to beacon_Users if they don't exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Users' AND COLUMN_NAME = 'Username')
    ALTER TABLE beacon_Users ADD Username NVARCHAR(100) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Users' AND COLUMN_NAME = 'Bio')
    ALTER TABLE beacon_Users ADD Bio NVARCHAR(500) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Users' AND COLUMN_NAME = 'AvatarUrl')
    ALTER TABLE beacon_Users ADD AvatarUrl NVARCHAR(500) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Users' AND COLUMN_NAME = 'Website')
    ALTER TABLE beacon_Users ADD Website NVARCHAR(500) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Users' AND COLUMN_NAME = 'IsActive')
    ALTER TABLE beacon_Users ADD IsActive BIT NOT NULL DEFAULT 1;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_Users' AND COLUMN_NAME = 'UpdatedAt')
    ALTER TABLE beacon_Users ADD UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE();
GO

PRINT 'Added missing columns to beacon_Users successfully.';
GO
