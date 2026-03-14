-- =====================================
-- Avatar System Database Migration
-- =====================================

-- Add avatar_data column to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS avatar_data JSONB DEFAULT NULL;

-- Add comment
COMMENT ON COLUMN users.avatar_data IS 'Avatar customization data (face, hair, eyes, mouth, colors)';

-- Example avatar_data structure:
-- {
--   "face": 0,
--   "hair": 2,
--   "eyes": 1,
--   "mouth": 0,
--   "skinColor": "#FFDBB6",
--   "hairColor": "#4A3728",
--   "clothColor": "#4A90E2"
-- }

-- Verify the change
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name = 'avatar_data';
