-- ============================================================
-- Beacon CMS — Fix AuditLogs Table (Rename & Add Columns)
-- Run this in SSMS against the [blog] database
-- ============================================================

USE [blog];
GO

-- 1. Rename table from Singular to Plural if it exists
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'beacon_AuditLog')
BEGIN
    EXEC sp_rename 'beacon_AuditLog', 'beacon_AuditLogs';
    PRINT 'Renamed beacon_AuditLog to beacon_AuditLogs';
END
GO

-- 2. Add UserEmail
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_AuditLogs' AND COLUMN_NAME = 'UserEmail')
BEGIN
    ALTER TABLE beacon_AuditLogs ADD UserEmail NVARCHAR(255) NULL;
    PRINT 'Added UserEmail to beacon_AuditLogs';
END
GO

-- 3. Add Details
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_AuditLogs' AND COLUMN_NAME = 'Details')
BEGIN
    ALTER TABLE beacon_AuditLogs ADD Details NVARCHAR(MAX) NULL;
    PRINT 'Added Details to beacon_AuditLogs';
END
GO

-- 4. Add IpAddress
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'beacon_AuditLogs' AND COLUMN_NAME = 'IpAddress')
BEGIN
    ALTER TABLE beacon_AuditLogs ADD IpAddress NVARCHAR(45) NULL;
    PRINT 'Added IpAddress to beacon_AuditLogs';
END
GO

PRINT 'AuditLogs table fixed successfully.';
GO
