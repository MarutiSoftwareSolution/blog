-- ============================================================
-- Remove Revisions and SchemaVersions Tables
-- ============================================================

USE [blog];
GO

PRINT 'Removing Revisions table...';
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'beacon_Revisions')
BEGIN
    DROP TABLE beacon_Revisions;
    PRINT 'Successfully dropped beacon_Revisions';
END
ELSE
BEGIN
    PRINT 'beacon_Revisions table does not exist';
END
GO

PRINT 'Removing beacon_SchemaVersion table...';
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'beacon_SchemaVersion')
BEGIN
    DROP TABLE beacon_SchemaVersion;
    PRINT 'Successfully dropped beacon_SchemaVersion';
END
ELSE
BEGIN
    PRINT 'beacon_SchemaVersion table does not exist';
END
GO

PRINT 'Table removal script complete.';
GO
