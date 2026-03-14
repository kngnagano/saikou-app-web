-- 本気の部屋 データベーステーブル作成
-- Version: MVP 1.0
-- 実装日: 2026-02-22

-- 1. 本気の部屋の挑戦テーブル
CREATE TABLE IF NOT EXISTS serious_room_challenges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) NOT NULL,
  buddy_id UUID REFERENCES users(id) NOT NULL,
  level INTEGER NOT NULL CHECK (level BETWEEN 1 AND 30),
  challenge_days INTEGER NOT NULL,
  allowed_fail_days INTEGER NOT NULL,
  deposit_points INTEGER NOT NULL, -- MVP版: ポイント制（後でリアルマネーに変更）
  user_share_points INTEGER NOT NULL,
  buddy_share_points INTEGER NOT NULL,
  declaration TEXT NOT NULL CHECK (length(declaration) <= 200),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'succeeded', 'failed', 'cancelled', 'buddy_dropped')),
  user_succeeded_days INTEGER DEFAULT 0,
  user_failed_days INTEGER DEFAULT 0,
  buddy_succeeded_days INTEGER DEFAULT 0,
  buddy_failed_days INTEGER DEFAULT 0,
  user_failed BOOLEAN DEFAULT FALSE,
  buddy_failed BOOLEAN DEFAULT FALSE,
  user_paid_with_credit BOOLEAN DEFAULT FALSE,
  buddy_paid_with_credit BOOLEAN DEFAULT FALSE,
  succeeded_at TIMESTAMP,
  failed_at TIMESTAMP,
  dropped_user_id UUID REFERENCES users(id),
  dropped_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. 挑戦リクエストテーブル
CREATE TABLE IF NOT EXISTS challenge_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  requester_id UUID REFERENCES users(id) NOT NULL,
  buddy_id UUID REFERENCES users(id) NOT NULL,
  level INTEGER NOT NULL CHECK (level BETWEEN 1 AND 30),
  deposit_points INTEGER NOT NULL,
  user_share_points INTEGER NOT NULL,
  declaration TEXT NOT NULL CHECK (length(declaration) <= 200),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'expired', 'cancelled')),
  expires_at TIMESTAMP NOT NULL,
  approved_at TIMESTAMP,
  rejected_at TIMESTAMP,
  cancel_reason TEXT,
  cancelled_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 3. 称号テーブル
CREATE TABLE IF NOT EXISTS titles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) NOT NULL,
  level INTEGER NOT NULL CHECK (level BETWEEN 1 AND 30),
  title TEXT NOT NULL,
  challenge_id UUID REFERENCES serious_room_challenges(id) NOT NULL,
  earned_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, level)
);

-- 4. ユーザーポイントテーブル（MVP版: 架空ポイント）
CREATE TABLE IF NOT EXISTS user_points (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) NOT NULL UNIQUE,
  balance INTEGER DEFAULT 500 CHECK (balance >= 0), -- 初期ポイント500（¥5,000相当）
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 5. ポイント履歴テーブル
CREATE TABLE IF NOT EXISTS point_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) NOT NULL,
  challenge_id UUID REFERENCES serious_room_challenges(id),
  amount INTEGER NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('deposit', 'refund', 'earn', 'spend')),
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 6. 挑戦日次履歴テーブル（挑戦の進捗を日ごとに記録）
CREATE TABLE IF NOT EXISTS challenge_daily_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id UUID REFERENCES serious_room_challenges(id) NOT NULL,
  user_id UUID REFERENCES users(id) NOT NULL,
  date DATE NOT NULL,
  is_succeeded BOOLEAN DEFAULT FALSE,
  committed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(challenge_id, user_id, date)
);

-- インデックス作成
CREATE INDEX IF NOT EXISTS idx_challenges_user_id ON serious_room_challenges(user_id);
CREATE INDEX IF NOT EXISTS idx_challenges_buddy_id ON serious_room_challenges(buddy_id);
CREATE INDEX IF NOT EXISTS idx_challenges_status ON serious_room_challenges(status);
CREATE INDEX IF NOT EXISTS idx_requests_buddy_id ON challenge_requests(buddy_id);
CREATE INDEX IF NOT EXISTS idx_requests_status ON challenge_requests(status);
CREATE INDEX IF NOT EXISTS idx_titles_user_id ON titles(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_history_challenge_id ON challenge_daily_history(challenge_id);
CREATE INDEX IF NOT EXISTS idx_daily_history_date ON challenge_daily_history(date);

-- 初期データ挿入関数（既存ユーザーに初期ポイント付与）
CREATE OR REPLACE FUNCTION initialize_user_points()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_points (user_id, balance)
  VALUES (NEW.id, 500)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- トリガー作成（新規ユーザー登録時に自動でポイント付与）
DROP TRIGGER IF EXISTS trigger_initialize_user_points ON users;
CREATE TRIGGER trigger_initialize_user_points
AFTER INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION initialize_user_points();

-- 既存ユーザーにポイントを付与
INSERT INTO user_points (user_id, balance)
SELECT id, 500
FROM users
ON CONFLICT (user_id) DO NOTHING;

-- RLS (Row Level Security) 設定
ALTER TABLE serious_room_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE titles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE point_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_daily_history ENABLE ROW LEVEL SECURITY;

-- RLSポリシー: 挑戦テーブル（自分と相棒のみ閲覧可能）
CREATE POLICY challenges_select_policy ON serious_room_challenges
  FOR SELECT
  USING (auth.uid() = user_id OR auth.uid() = buddy_id);

CREATE POLICY challenges_insert_policy ON serious_room_challenges
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY challenges_update_policy ON serious_room_challenges
  FOR UPDATE
  USING (auth.uid() = user_id OR auth.uid() = buddy_id);

-- RLSポリシー: 挑戦リクエスト（自分と相棒のみ閲覧可能）
CREATE POLICY requests_select_policy ON challenge_requests
  FOR SELECT
  USING (auth.uid() = requester_id OR auth.uid() = buddy_id);

CREATE POLICY requests_insert_policy ON challenge_requests
  FOR INSERT
  WITH CHECK (auth.uid() = requester_id);

CREATE POLICY requests_update_policy ON challenge_requests
  FOR UPDATE
  USING (auth.uid() = requester_id OR auth.uid() = buddy_id);

-- RLSポリシー: 称号（自分の称号のみ閲覧・挿入可能）
CREATE POLICY titles_select_policy ON titles
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY titles_insert_policy ON titles
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLSポリシー: ポイント残高（自分のみ閲覧可能）
CREATE POLICY points_select_policy ON user_points
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY points_update_policy ON user_points
  FOR UPDATE
  USING (auth.uid() = user_id);

-- RLSポリシー: ポイント履歴（自分のみ閲覧可能）
CREATE POLICY transactions_select_policy ON point_transactions
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY transactions_insert_policy ON point_transactions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLSポリシー: 挑戦日次履歴（自分と相棒のみ閲覧可能）
CREATE POLICY daily_history_select_policy ON challenge_daily_history
  FOR SELECT
  USING (
    auth.uid() = user_id OR
    auth.uid() IN (
      SELECT buddy_id FROM serious_room_challenges WHERE id = challenge_id
      UNION
      SELECT user_id FROM serious_room_challenges WHERE id = challenge_id
    )
  );

CREATE POLICY daily_history_insert_policy ON challenge_daily_history
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 完了
-- 実行手順:
-- 1. Supabase SQL Editor を開く: https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/sql
-- 2. このSQLをコピー＆ペースト
-- 3. 「RUN」をクリック
-- 4. 成功メッセージを確認
