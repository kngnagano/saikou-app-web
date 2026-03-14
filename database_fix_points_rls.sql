-- ========================================
-- Fix user_points RLS for INSERT
-- ========================================

-- 1. 現在のINSERTポリシーを削除
DROP POLICY IF EXISTS points_insert_policy ON user_points;

-- 2. 新しいINSERTポリシーを作成（ログイン中のユーザーが自分のレコードを作成可能）
CREATE POLICY points_insert_policy ON user_points 
FOR INSERT 
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- 3. SELECTポリシーも再確認（念のため）
DROP POLICY IF EXISTS points_select_policy ON user_points;
CREATE POLICY points_select_policy ON user_points 
FOR SELECT 
TO authenticated
USING (auth.uid() = user_id);

-- 4. UPDATEポリシーも再確認（念のため）
DROP POLICY IF EXISTS points_update_policy ON user_points;
CREATE POLICY points_update_policy ON user_points 
FOR UPDATE 
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 5. テストユーザーに初期ポイントを付与（既存レコードがある場合は更新）
INSERT INTO user_points (user_id, balance)
SELECT id, 2000 
FROM users 
WHERE email IN ('rikki5.929@gmail.com', 'riki.happy@outlook.jp')
ON CONFLICT (user_id) 
DO UPDATE SET balance = 2000, updated_at = NOW();

-- 6. 確認クエリ
SELECT 
  u.id,
  u.email, 
  u.display_name, 
  u.current_streak AS 継続日数,
  up.balance AS ポイント残高,
  up.created_at AS ポイント作成日時,
  up.updated_at AS ポイント更新日時
FROM users u 
LEFT JOIN user_points up ON u.id = up.user_id
WHERE u.email IN ('rikki5.929@gmail.com', 'riki.happy@outlook.jp')
ORDER BY u.email;

-- 7. 全ポリシーを確認
SELECT 
  schemaname, 
  tablename, 
  policyname, 
  permissive, 
  roles, 
  cmd, 
  qual, 
  with_check 
FROM pg_policies 
WHERE tablename = 'user_points';

-- ========================================
-- 実行手順:
-- 1. https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/sql を開く
-- 2. このSQLをコピー＆ペーストして RUN をクリック
-- 3. 最後の確認クエリで両ユーザーの balance = 2000 を確認
-- 4. ブラウザで Ctrl+Shift+R、ログアウト→再ログインして確認
-- ========================================
