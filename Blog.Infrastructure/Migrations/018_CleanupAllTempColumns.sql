-- =======================================================
-- REMOVE LEFTOVER TEMP COLUMNS ACROSS ALL TABLES
-- (Leftovers from Integer to GUID Migration)
-- =======================================================

-- Categories
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempId' AND Object_ID = Object_ID('Categories')) ALTER TABLE Categories DROP COLUMN TempId;
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempAuthorId' AND Object_ID = Object_ID('Categories')) ALTER TABLE Categories DROP COLUMN TempAuthorId;
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempParentId' AND Object_ID = Object_ID('Categories')) ALTER TABLE Categories DROP COLUMN TempParentId;

-- Comments
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempId' AND Object_ID = Object_ID('Comments')) ALTER TABLE Comments DROP COLUMN TempId;
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempParentId' AND Object_ID = Object_ID('Comments')) ALTER TABLE Comments DROP COLUMN TempParentId;
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempPostId' AND Object_ID = Object_ID('Comments')) ALTER TABLE Comments DROP COLUMN TempPostId;

-- Media
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempId' AND Object_ID = Object_ID('Media')) ALTER TABLE Media DROP COLUMN TempId;
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempUploadedBy' AND Object_ID = Object_ID('Media')) ALTER TABLE Media DROP COLUMN TempUploadedBy;

-- Pages
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempId' AND Object_ID = Object_ID('Pages')) ALTER TABLE Pages DROP COLUMN TempId;
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempAuthorId' AND Object_ID = Object_ID('Pages')) ALTER TABLE Pages DROP COLUMN TempAuthorId;
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempParentId' AND Object_ID = Object_ID('Pages')) ALTER TABLE Pages DROP COLUMN TempParentId;
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempFeaturedImageId' AND Object_ID = Object_ID('Pages')) ALTER TABLE Pages DROP COLUMN TempFeaturedImageId;

-- PostCategories
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempCategoryId' AND Object_ID = Object_ID('PostCategories')) ALTER TABLE PostCategories DROP COLUMN TempCategoryId;
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempPostId' AND Object_ID = Object_ID('PostCategories')) ALTER TABLE PostCategories DROP COLUMN TempPostId;

-- PostTags
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempPostId' AND Object_ID = Object_ID('PostTags')) ALTER TABLE PostTags DROP COLUMN TempPostId;
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempTagId' AND Object_ID = Object_ID('PostTags')) ALTER TABLE PostTags DROP COLUMN TempTagId;

-- Settings
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempUserId' AND Object_ID = Object_ID('Settings')) ALTER TABLE Settings DROP COLUMN TempUserId;

-- Tags
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempId' AND Object_ID = Object_ID('Tags')) ALTER TABLE Tags DROP COLUMN TempId;
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempAuthorId' AND Object_ID = Object_ID('Tags')) ALTER TABLE Tags DROP COLUMN TempAuthorId;

-- Users
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = 'TempId' AND Object_ID = Object_ID('Users')) ALTER TABLE Users DROP COLUMN TempId;

GO
