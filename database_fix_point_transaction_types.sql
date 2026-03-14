-- Fix point_transactions type constraint to include new bonus types
-- Execute this in Supabase SQL Editor: https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/sql

-- Step 1: Drop the existing CHECK constraint
ALTER TABLE point_transactions
DROP CONSTRAINT IF EXISTS point_transactions_type_check;

-- Step 2: Add new CHECK constraint with all types
ALTER TABLE point_transactions
ADD CONSTRAINT point_transactions_type_check
CHECK (type IN (
  'deposit',           -- 挑戦開始時のデポジット
  'refund',            -- 挑戦成功時の返還
  'earn',              -- ポイント獲得
  'spend',             -- ポイント消費
  'login_bonus',       -- ログインボーナス（NEW）
  'invitation_bonus',  -- 招待ボーナス（NEW）
  'forfeit'            -- キャンセル時の没収（NEW）
));

-- Step 3: Verify the constraint
SELECT 
  conname AS constraint_name,
  pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'point_transactions'::regclass
  AND conname = 'point_transactions_type_check';

-- Step 4: Test insert (should succeed now)
-- Uncomment to test:
-- INSERT INTO point_transactions (user_id, amount, type, description)
-- SELECT id, 25, 'login_bonus', 'テスト用ログインボーナス'
-- FROM users
-- WHERE email = 'rikki5.929@gmail.com'
-- LIMIT 1;

-- Step 5: Verify existing transactions
SELECT 
  type,
  COUNT(*) AS count,
  SUM(amount) AS total_amount
FROM point_transactions
GROUP BY type
ORDER BY type;
