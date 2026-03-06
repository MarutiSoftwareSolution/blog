-- 1. Remove Membership & Newsletter system tables
IF OBJECT_ID('dbo.MembersLabels', 'U') IS NOT NULL DROP TABLE dbo.MembersLabels;
IF OBJECT_ID('dbo.MembersNewsletters', 'U') IS NOT NULL DROP TABLE dbo.MembersNewsletters;
IF OBJECT_ID('dbo.Members', 'U') IS NOT NULL DROP TABLE dbo.Members;
IF OBJECT_ID('dbo.Labels', 'U') IS NOT NULL DROP TABLE dbo.Labels;
IF OBJECT_ID('dbo.Emails', 'U') IS NOT NULL DROP TABLE dbo.Emails;
IF OBJECT_ID('dbo.Newsletters', 'U') IS NOT NULL DROP TABLE dbo.Newsletters;


-- 3. Remove Content / Miscellaneous System Tables
IF OBJECT_ID('dbo.PostsAuthors', 'U') IS NOT NULL DROP TABLE dbo.PostsAuthors;
IF OBJECT_ID('dbo.PostRevisions', 'U') IS NOT NULL DROP TABLE dbo.PostRevisions;
IF OBJECT_ID('dbo.Revisions', 'U') IS NOT NULL DROP TABLE dbo.Revisions; -- Dropping both naming conventions
IF OBJECT_ID('dbo.Snippets', 'U') IS NOT NULL DROP TABLE dbo.Snippets;
IF OBJECT_ID('dbo.Redirects', 'U') IS NOT NULL DROP TABLE dbo.Redirects;

-- 4. Clean up unused columns on existing tables
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Categories') AND name = 'Color')
BEGIN
    ALTER TABLE dbo.Categories DROP COLUMN Color;
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Categories') AND name = 'ParentId')
BEGIN
    ALTER TABLE dbo.Categories DROP COLUMN ParentId;
END
