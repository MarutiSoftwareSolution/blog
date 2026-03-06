IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Categories') AND name = 'Color')
BEGIN
    ALTER TABLE beacon_Categories ADD Color NVARCHAR(50) NULL DEFAULT '#e8f5e9' WITH VALUES;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Tags') AND name = 'Color')
BEGIN
    ALTER TABLE beacon_Tags ADD Color NVARCHAR(50) NULL DEFAULT '#e3f2fd' WITH VALUES;
END
