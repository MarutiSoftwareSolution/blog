-- ============================================================
-- Beacon CMS - 002_SeedAdmin.sql
-- Seeds default site settings (admin user seeded via C# seeder)
-- ============================================================

-- Default site settings
INSERT OR IGNORE INTO beacon_Settings (Key, Value, Group_) VALUES
    ('site_name',            'My Beacon Blog',  'general'),
    ('site_tagline',         'Powered by Beacon CMS', 'general'),
    ('site_installed',       'true',            'general'),
    ('comments_enabled',     'true',            'general'),
    ('comments_moderation',  'true',            'general'),
    ('posts_per_page',       '10',              'general'),
    ('theme',                'Standard',        'general'),
    ('timezone',             'UTC',             'general'),
    ('language',             'en',              'general');

-- Record this migration
INSERT OR IGNORE INTO beacon_SchemaVersion (Version, Description)
VALUES (2, 'Seed default settings');
