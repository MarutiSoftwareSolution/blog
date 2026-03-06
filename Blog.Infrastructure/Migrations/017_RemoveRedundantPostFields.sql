-- =======================================================
-- REMOVE REDUNDANT POST FIELDS
-- =======================================================

IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'Content' AND Object_ID = Object_ID('Posts'))
BEGIN
    ALTER TABLE Posts DROP COLUMN Content;
END
GO

IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'Summary' AND Object_ID = Object_ID('Posts'))
BEGIN
    ALTER TABLE Posts DROP COLUMN Summary;
END
GO

IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'FeaturedImageId' AND Object_ID = Object_ID('Posts'))
BEGIN
    ALTER TABLE Posts DROP COLUMN FeaturedImageId;
END
GO

IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempId' AND Object_ID = Object_ID('Posts'))
BEGIN
    ALTER TABLE Posts DROP COLUMN TempId;
END
GO

IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempAuthorId' AND Object_ID = Object_ID('Posts'))
BEGIN
    ALTER TABLE Posts DROP COLUMN TempAuthorId;
END
GO

IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempFeaturedImageId' AND Object_ID = Object_ID('Posts'))
BEGIN
    ALTER TABLE Posts DROP COLUMN TempFeaturedImageId;
END
GO

IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'Lexical' AND Object_ID = Object_ID('Posts'))
BEGIN
    ALTER TABLE Posts DROP COLUMN Lexical;
END
GO
