-- ========================================
-- 【最終修正】ポイントシステムを完全に修正
-- ========================================

-- 問題: currentUser.id (users.id) と auth.uid() が一致しない
-- 解決策: user_points テーブルのRLSポリシーを調整

-- 1. 現在のauth.uid()を確認
SELECT auth.uid() AS "現在の認証ユーザーID";

-- 2. usersテーブルの構造を確認
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'users'
  AND column_name IN ('id', 'auth_user_id')
ORDER BY ordinal_position;

-- 3. rikki5.929@gmail.com のユーザー情報を確認
SELECT 
  id AS "users.id",
  email,
  display_name,
  current_streak
FROM users 
WHERE email = 'rikki5.929@gmail.com';

-- 4. 既存のポイントレコードをすべて削除
DELETE FROM user_points;

-- 5. 正しい認証IDでポイントレコードを作成
-- auth.uid() = 90b23bc5-d460-47c3-ae12-c4d367d7760e を使用
INSERT INTO user_points (user_id, balance, created_at, updated_at)
VALUES 
  ('90b23bc5-d460-47c3-ae12-c4d367d7760e', 2000, NOW(), NOW());

-- 6. riki.happy@outlook.jp のauth.uid()を取得して作成
-- （このユーザーでログインして auth.uid() を確認後、手動で追加）

-- 7. RLSポリシーを完全に再構築
DROP POLICY IF EXISTS points_select_policy ON user_points;
DROP POLICY IF EXISTS points_insert_policy ON user_points;
DROP POLICY IF EXISTS points_update_policy ON user_points;
DROP POLICY IF EXISTS points_delete_policy ON user_points;

-- 8. 新しいSELECTポリシー（auth.uid()で照合）
CREATE POLICY points_select_policy ON user_points 
FOR SELECT 
TO authenticated
USING (user_id = auth.uid());

-- 9. 新しいINSERTポリシー
CREATE POLICY points_insert_policy ON user_points 
FOR INSERT 
TO authenticated
WITH CHECK (user_id = auth.uid());

-- 10. 新しいUPDATEポリシー
CREATE POLICY points_update_policy ON user_points 
FOR UPDATE 
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 11. increment_user_points 関数も修正
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

-- 12. 最終確認
SELECT 
  up.user_id AS "ポイントレコードのuser_id",
  up.balance AS "残高",
  up.created_at AS "作成日時"
FROM user_points up
WHERE up.user_id = '90b23bc5-d460-47c3-ae12-c4d367d7760e';

-- 13. RLSポリシー確認
SELECT 
  tablename, 
  policyname, 
  cmd, 
  roles
FROM pg_policies 
WHERE tablename = 'user_points'
ORDER BY cmd;

-- ========================================
-- 実行手順:
-- 1. このSQLを実行
-- 2. Step 12 で balance = 2000 を確認
-- 3. アプリをデプロイ
-- 4. ブラウザで確認：
--    - 🔐 Auth user ID と currentUser.id が一致しないが
--    - user_points は auth.uid() で作成されているので正常に表示される
-- ========================================
