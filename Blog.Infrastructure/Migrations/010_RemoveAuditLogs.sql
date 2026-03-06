-- ============================================================
-- Beacon CMS — Remove Audit Logs Table
-- Run this in SSMS against the [blog] database
-- ============================================================

USE [blog];
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'beacon_AuditLogs')
BEGIN
    DROP TABLE beacon_AuditLogs;
    PRINT 'Dropped table beacon_AuditLogs';
END
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'beacon_AuditLog')
BEGIN
    DROP TABLE beacon_AuditLog;
    PRINT 'Dropped table beacon_AuditLog (singular version)';
END
GO
