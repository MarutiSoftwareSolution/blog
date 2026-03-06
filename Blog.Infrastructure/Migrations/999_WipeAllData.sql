-- ============================================================
-- Wipe ALL data from the blog database
-- Run manually: sqlcmd -S "(localdb)\MSSQLLocalDB" -d blog -i Blog.Infrastructure\Migrations\999_WipeAllData.sql
-- ============================================================

-- Disable FK checks temporarily
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

-- Junction / mapping tables first
DELETE FROM PostCategories;
DELETE FROM PostTags;
DELETE FROM PermissionsRoles;
DELETE FROM RolesUsers;

-- Content tables
DELETE FROM Comments;
DELETE FROM Media;
DELETE FROM Posts;
DELETE FROM Pages;

-- Taxonomy
DELETE FROM Categories;
DELETE FROM Tags;

-- RBAC
DELETE FROM Permissions;
DELETE FROM Roles;

-- Config
DELETE FROM Settings;

-- Users last (referenced by FKs)
DELETE FROM Users;

-- Re-enable FK checks
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';

PRINT 'All data wiped successfully.';
