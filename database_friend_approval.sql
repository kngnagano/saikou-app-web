-- フレンド承認システム用のデータベース変更
-- Supabase SQL Editorで実行してください

-- 1. friendsテーブルにstatusカラムを追加
ALTER TABLE friends 
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'pending';

-- 2. 既存のフレンド関係はすべて承認済みに設定
UPDATE friends 
SET status = 'approved' 
WHERE status IS NULL OR status = '';

-- 3. statusのインデックスを追加（検索高速化）
CREATE INDEX IF NOT EXISTS idx_friends_status ON friends(status);

-- 4. 確認用クエリ
SELECT * FROM friends LIMIT 5;
