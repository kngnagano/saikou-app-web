-- Saikou! v3.0 Database Migration
-- 実行日: 2026-02-20
-- 目的: invited_countカラムの追加

-- 1. usersテーブルにinvited_countカラムを追加
ALTER TABLE users ADD COLUMN IF NOT EXISTS invited_count INTEGER DEFAULT 0;

-- 2. 既存ユーザーのinvited_countを0に初期化（既に存在する場合はスキップ）
UPDATE users SET invited_count = 0 WHERE invited_count IS NULL;

-- 3. インデックスの作成（パフォーマンス向上）
CREATE INDEX IF NOT EXISTS idx_users_invited_count ON users(invited_count);

-- 4. 確認クエリ
-- 以下のクエリを実行して、カラムが正しく追加されたか確認してください
-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'users' AND column_name = 'invited_count';

-- 完了メッセージ
SELECT 'Migration completed successfully. Column invited_count added to users table.' AS status;
