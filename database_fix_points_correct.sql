-- ========================================
-- 【最終修正】user_points を users.id で作成
-- ========================================

-- 1. 現在のusersテーブルを確認
SELECT 
  id,
  email,
  display_name,
  current_streak
FROM users 
WHERE email IN ('rikki5.929@gmail.com', 'riki.happy@outlook.jp')
ORDER BY email;

-- 2. 既存のポイントレコードをすべて削除
DELETE FROM user_points;

-- 3. usersテーブルに存在するIDでポイントレコードを作成
INSERT INTO user_points (user_id, balance, created_at, updated_at)
SELECT 
  id, 
  2000,
  NOW(),
  NOW()
FROM users 
WHERE email IN ('rikki5.929@gmail.com', 'riki.happy@outlook.jp');

-- 4. RLSポリシーを再構築（users.id で照合）
DROP POLICY IF EXISTS points_select_policy ON user_points;
DROP POLICY IF EXISTS points_insert_policy ON user_points;
DROP POLICY IF EXISTS points_update_policy ON user_points;

CREATE POLICY points_select_policy ON user_points 
FOR SELECT 
TO authenticated
USING (
  user_id IN (
    SELECT id FROM users WHERE id = user_id
  )
);

CREATE POLICY points_insert_policy ON user_points 
FOR INSERT 
TO authenticated
WITH CHECK (
  user_id IN (
    SELECT id FROM users WHERE id = user_id
  )
);

CREATE POLICY points_update_policy ON user_points 
FOR UPDATE 
TO authenticated
USING (
  user_id IN (
    SELECT id FROM users WHERE id = user_id
  )
)
WITH CHECK (
  user_id IN (
    SELECT id FROM users WHERE id = user_id
  )
);

-- 5. increment_user_points 関数を作成
CREATE OR REPLACE FUNCTION increment_user_points(
  p_user_id UUID,
  p_amount INTEGER
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE user_points
  SET balance = balance + p_amount,
      updated_at = NOW()
  WHERE user_id = p_user_id;
  
  IF NOT FOUND THEN
    INSERT INTO user_points (user_id, balance, created_at, updated_at)
    VALUES (p_user_id, GREATEST(p_amount, 0), NOW(), NOW());
  END IF;
END;
$$;

-- 6. 最終確認
SELECT 
  u.email,
  u.display_name,
  u.current_streak AS 継続日数,
  up.user_id,
  up.balance AS ポイント残高,
  up.created_at
FROM users u
INNER JOIN user_points up ON u.id = up.user_id
WHERE u.email IN ('rikki5.929@gmail.com', 'riki.happy@outlook.jp')
ORDER BY u.email;
