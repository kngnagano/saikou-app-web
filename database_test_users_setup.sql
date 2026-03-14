-- テスト用: 特定の2人のユーザーにポイント付与と継続日数設定
-- Version: 1.1（修正版）
-- 実行日: 2026-02-22

-- ユーザー1（rikki5.929@gmail.com）に500ポイント追加
UPDATE user_points
SET balance = balance + 500, updated_at = NOW()
WHERE user_id = (SELECT id FROM users WHERE email = 'rikki5.929@gmail.com');

-- ユーザー2（riki.happy@outlook.jp）に500ポイント追加
UPDATE user_points
SET balance = balance + 500, updated_at = NOW()
WHERE user_id = (SELECT id FROM users WHERE email = 'riki.happy@outlook.jp');

-- ユーザー2の継続日数を7日に設定（updated_at を削除）
UPDATE users
SET current_streak = 7
WHERE email = 'riki.happy@outlook.jp';

-- 確認
SELECT 
  u.email, 
  u.display_name, 
  u.current_streak as 継続日数,
  up.balance as ポイント残高
FROM users u
LEFT JOIN user_points up ON u.id = up.user_id
WHERE u.email IN ('rikki5.929@gmail.com', 'riki.happy@outlook.jp');

-- 完了
-- 実行手順:
-- 1. Supabase SQL Editor を開く: https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/sql
-- 2. このSQLをコピー＆ペースト
-- 3. 「RUN」をクリック
-- 4. 成功メッセージと確認結果を確認
