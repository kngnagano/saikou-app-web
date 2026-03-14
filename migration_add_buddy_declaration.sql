-- Migration: Add individual declarations for user and buddy
-- This allows each person to set their own challenge declaration/goal

-- Add buddy_declaration to challenge_requests table
ALTER TABLE challenge_requests 
ADD COLUMN IF NOT EXISTS buddy_declaration TEXT CHECK (length(buddy_declaration) <= 200);

-- Rename existing declaration to user_declaration for clarity
ALTER TABLE challenge_requests 
RENAME COLUMN declaration TO user_declaration;

-- Add buddy_declaration to serious_room_challenges table
ALTER TABLE serious_room_challenges 
ADD COLUMN IF NOT EXISTS buddy_declaration TEXT CHECK (length(buddy_declaration) <= 200);

-- Rename existing declaration to user_declaration for clarity
ALTER TABLE serious_room_challenges 
RENAME COLUMN declaration TO user_declaration;

-- Verify the changes
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN ('challenge_requests', 'serious_room_challenges')
  AND column_name LIKE '%declaration%'
ORDER BY table_name, column_name;
