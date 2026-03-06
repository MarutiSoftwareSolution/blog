-- Migration 019: Remove Code Injection Fields
-- This script removes the CodeInjectionHead and CodeInjectionFoot columns from the Posts table.

BEGIN TRANSACTION;

BEGIN TRY
    -- Check if the CodeInjectionHead column exists before trying to drop it
    IF EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'Posts' AND COLUMN_NAME = 'CodeInjectionHead'
    )
    BEGIN
        ALTER TABLE [Posts]
        DROP COLUMN [CodeInjectionHead];
        PRINT 'Dropped CodeInjectionHead from Posts table.';
    END
    ELSE
    BEGIN
        PRINT 'Column CodeInjectionHead does not exist in Posts table.';
    END

    -- Check if the CodeInjectionFoot column exists before trying to drop it
    IF EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'Posts' AND COLUMN_NAME = 'CodeInjectionFoot'
    )
    BEGIN
        ALTER TABLE [Posts]
        DROP COLUMN [CodeInjectionFoot];
        PRINT 'Dropped CodeInjectionFoot from Posts table.';
    END
    ELSE
    BEGIN
        PRINT 'Column CodeInjectionFoot does not exist in Posts table.';
    END

    COMMIT TRANSACTION;
    PRINT 'Migration 019 completed successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error occurred during migration 019. Transaction rolled back.';
    PRINT ERROR_MESSAGE();
END CATCH;
