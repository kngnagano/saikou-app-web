-- ========================================
-- rikki5.929@gmail.com の今日の達成状況リセット
-- テスト用
-- ========================================

-- ① 対象ユーザーのIDを確認（実行して確認する）
SELECT u.id, u.display_name, u.email
FROM users u
JOIN auth.users a ON a.id = u.id
WHERE a.email = 'rikki5.929@gmail.com';

-- ② 今日の daily_status を削除（日本時間 2026-02-23）
-- ※ 上記①で確認したuser_idを使って実行
DELETE FROM daily_status
WHERE user_id = (
  SELECT u.id FROM users u
  JOIN auth.users a ON a.id = u.id
  WHERE a.email = 'rikki5.929@gmail.com'
)
AND date = '2026-02-23';

-- ③ 確認クエリ（削除後に空になっていることを確認）
SELECT *
FROM daily_status
WHERE user_id = (
  SELECT u.id FROM users u
  JOIN auth.users a ON a.id = u.id
  WHERE a.email = 'rikki5.929@gmail.com'
)
AND date = '2026-02-23';

-- ④ users テーブルの current_streak も必要に応じてリセット
-- （継続日数を巻き戻す場合のみ使用・通常は不要）
-- UPDATE users
-- SET current_streak = current_streak - 1,
--     last_commit_date = '2026-02-22'
-- WHERE id = (
--   SELECT u.id FROM users u
--   JOIN auth.users a ON a.id = u.id
--   WHERE a.email = 'rikki5.929@gmail.com'
-- );
