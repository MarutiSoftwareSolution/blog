DECLARE @ConstraintName nvarchar(200)

-- 1. categories
SELECT @ConstraintName = Name FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID('beacon_Categories')
AND parent_column_id = (SELECT column_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Categories') AND name = 'Color')

IF @ConstraintName IS NOT NULL
EXEC('ALTER TABLE beacon_Categories DROP CONSTRAINT [' + @ConstraintName + ']')

IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'Color' AND Object_ID = Object_ID('beacon_Categories'))
BEGIN
    ALTER TABLE beacon_Categories DROP COLUMN Color
END

-- 2. Tags
SELECT @ConstraintName = Name FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID('beacon_Tags')
AND parent_column_id = (SELECT column_id FROM sys.columns WHERE object_id = OBJECT_ID('beacon_Tags') AND name = 'Color')

IF @ConstraintName IS NOT NULL
EXEC('ALTER TABLE beacon_Tags DROP CONSTRAINT [' + @ConstraintName + ']')

IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'Color' AND Object_ID = Object_ID('beacon_Tags'))
BEGIN
    ALTER TABLE beacon_Tags DROP COLUMN Color
END
