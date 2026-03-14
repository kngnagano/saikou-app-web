-- ===================================
-- Saikou! Database Cleanup Script
-- ===================================
-- Purpose: Clean up test data and reset database to production-ready state
-- ⚠️ WARNING: This will delete ALL data except the main user (rikki5.929@gmail.com)
-- Run this script in Supabase SQL Editor: https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/sql

-- ===================================
-- Step 1: Identify the main user
-- ===================================
DO $$
DECLARE
  main_user_id UUID;
BEGIN
  -- Get the main user ID
  SELECT id INTO main_user_id FROM users WHERE email = 'rikki5.929@gmail.com';
  
  IF main_user_id IS NULL THEN
    RAISE EXCEPTION 'Main user not found! Please update the email in this script.';
  END IF;
  
  RAISE NOTICE 'Main user ID: %', main_user_id;
  
  -- ===================================
  -- Step 2: Delete test data
  -- ===================================
  
  -- Delete point transactions for test users
  DELETE FROM point_transactions 
  WHERE user_id IN (SELECT id FROM users WHERE id != main_user_id);
  
  -- Delete challenge daily history for test users
  DELETE FROM challenge_daily_history 
  WHERE user_id IN (SELECT id FROM users WHERE id != main_user_id);
  
  -- Delete serious room challenges involving test users
  DELETE FROM serious_room_challenges 
  WHERE user_id IN (SELECT id FROM users WHERE id != main_user_id)
     OR buddy_id IN (SELECT id FROM users WHERE id != main_user_id);
  
  -- Delete challenge requests involving test users
  DELETE FROM challenge_requests 
  WHERE requester_id IN (SELECT id FROM users WHERE id != main_user_id)
     OR buddy_id IN (SELECT id FROM users WHERE id != main_user_id);
  
  -- Delete titles for test users
  DELETE FROM titles 
  WHERE user_id IN (SELECT id FROM users WHERE id != main_user_id);
  
  -- Delete friend relationships involving test users
  DELETE FROM friends 
  WHERE user_id IN (SELECT id FROM users WHERE id != main_user_id)
     OR friend_user_id IN (SELECT id FROM users WHERE id != main_user_id);
  
  -- Delete daily status for test users
  DELETE FROM daily_status 
  WHERE user_id IN (SELECT id FROM users WHERE id != main_user_id);
  
  -- Delete tasks for test users
  DELETE FROM tasks 
  WHERE user_id IN (SELECT id FROM users WHERE id != main_user_id);
  
  -- Delete user points for test users
  DELETE FROM user_points 
  WHERE user_id IN (SELECT id FROM users WHERE id != main_user_id);
  
  -- Delete test users (keep only main user)
  DELETE FROM users WHERE id != main_user_id;
  
  RAISE NOTICE 'Test data deleted successfully';
  
  -- ===================================
  -- Step 3: Reset main user data (optional - uncomment if needed)
  -- ===================================
  
  -- Reset user stats to starting state
  -- UPDATE users 
  -- SET current_streak = 0,
  --     best_streak = 0,
  --     invited_count = 0
  -- WHERE id = main_user_id;
  
  -- Reset user points to initial 500pt
  -- UPDATE user_points 
  -- SET balance = 500
  -- WHERE user_id = main_user_id;
  
  -- Delete all point transactions for main user
  -- DELETE FROM point_transactions WHERE user_id = main_user_id;
  
  -- Delete all challenges for main user
  -- DELETE FROM challenge_daily_history WHERE user_id = main_user_id;
  -- DELETE FROM serious_room_challenges WHERE user_id = main_user_id OR buddy_id = main_user_id;
  -- DELETE FROM challenge_requests WHERE requester_id = main_user_id OR buddy_id = main_user_id;
  
  -- Delete all titles for main user
  -- DELETE FROM titles WHERE user_id = main_user_id;
  
  -- Delete all friends for main user
  -- DELETE FROM friends WHERE user_id = main_user_id OR friend_user_id = main_user_id;
  
  -- Delete daily status for main user
  -- DELETE FROM daily_status WHERE user_id = main_user_id;
  
  -- Delete tasks for main user
  -- DELETE FROM tasks WHERE user_id = main_user_id;
  
  RAISE NOTICE 'Main user data reset completed (if uncommented)';
  
END $$;

-- ===================================
-- Step 4: Verification - Check remaining data
-- ===================================

-- Check users
SELECT 'users' AS table_name, COUNT(*) AS count FROM users;

-- Check tasks
SELECT 'tasks' AS table_name, COUNT(*) AS count FROM tasks;

-- Check daily_status
SELECT 'daily_status' AS table_name, COUNT(*) AS count FROM daily_status;

-- Check friends
SELECT 'friends' AS table_name, COUNT(*) AS count FROM friends;

-- Check user_points
SELECT 'user_points' AS table_name, COUNT(*) AS count FROM user_points;

-- Check point_transactions
SELECT 'point_transactions' AS table_name, COUNT(*) AS count FROM point_transactions;

-- Check serious_room_challenges
SELECT 'serious_room_challenges' AS table_name, COUNT(*) AS count FROM serious_room_challenges;

-- Check challenge_requests
SELECT 'challenge_requests' AS table_name, COUNT(*) AS count FROM challenge_requests;

-- Check challenge_daily_history
SELECT 'challenge_daily_history' AS table_name, COUNT(*) AS count FROM challenge_daily_history;

-- Check titles
SELECT 'titles' AS table_name, COUNT(*) AS count FROM titles;

-- ===================================
-- Step 5: Check main user status
-- ===================================

SELECT 
  'Main User Status' AS info,
  u.email,
  u.display_name,
  u.current_streak,
  u.best_streak,
  u.invited_count,
  up.balance AS points_balance
FROM users u
LEFT JOIN user_points up ON u.id = up.user_id
WHERE u.email = 'rikki5.929@gmail.com';

-- ===================================
-- DONE! Database is now clean
-- ===================================
