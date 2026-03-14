-- 短期目標・長期目標カラムの追加
ALTER TABLE users ADD COLUMN IF NOT EXISTS short_term_goal TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS long_term_goal TEXT;

-- 既存ユーザーのデフォルト値（任意）
UPDATE users SET short_term_goal = '' WHERE short_term_goal IS NULL;
UPDATE users SET long_term_goal = '' WHERE long_term_goal IS NULL;
