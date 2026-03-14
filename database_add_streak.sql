-- ユーザーテーブルに継続日数カラムを追加
-- Version: 1.0
-- 実装日: 2026-02-22

-- current_streak カラムを追加（現在の継続日数）
ALTER TABLE users ADD COLUMN IF NOT EXISTS current_streak INTEGER DEFAULT 0;

-- longest_streak カラムを追加（最長継続日数）
ALTER TABLE users ADD COLUMN IF NOT EXISTS longest_streak INTEGER DEFAULT 0;

-- last_commit_date カラムを追加（最後にコミットした日付）
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_commit_date DATE;

-- 既存ユーザーのデータを初期化
UPDATE users 
SET 
  current_streak = 0,
  longest_streak = 0,
  last_commit_date = NULL
WHERE current_streak IS NULL;

-- 完了
-- 実行手順:
-- 1. Supabase SQL Editor を開く: https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/sql
-- 2. このSQLをコピー＆ペースト
-- 3. 「RUN」をクリック
-- 4. 成功メッセージを確認
