-- =====================================================
-- Saikou! Phase 1 クエスト型タスク DB マイグレーション
-- =====================================================

-- 1. tasksテーブルにクエスト型カラムを追加
ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS task_type TEXT DEFAULT 'EXEC',
  ADD COLUMN IF NOT EXISTS target_value INTEGER DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS unit TEXT DEFAULT NULL;

-- task_type の制約（EXEC/COUNT/TIME）
ALTER TABLE tasks
  ADD CONSTRAINT IF NOT EXISTS tasks_task_type_check
  CHECK (task_type IN ('EXEC', 'COUNT', 'TIME'));

-- 2. task_logs テーブル（タスク実行記録）
CREATE TABLE IF NOT EXISTS task_logs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES users(id) ON DELETE CASCADE,
  task_id         UUID REFERENCES tasks(id) ON DELETE SET NULL,
  task_name       TEXT NOT NULL,
  task_type       TEXT NOT NULL CHECK (task_type IN ('EXEC','COUNT','TIME')),
  genre_id        INTEGER DEFAULT 0,
  target_value    INTEGER,
  actual_value    INTEGER,        -- 実際の達成値（回数 or 秒数）
  xp_earned       INTEGER DEFAULT 0,
  xp_multiplier   NUMERIC(3,2) DEFAULT 1.0,  -- 写真投稿で1.5倍など
  date            DATE NOT NULL DEFAULT CURRENT_DATE,
  completed_at    TIMESTAMPTZ DEFAULT NOW(),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_task_logs_user_date ON task_logs(user_id, date);

-- 3. RLS
ALTER TABLE task_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Users can manage own task_logs"
  ON task_logs FOR ALL
  USING (auth.uid() = (SELECT auth_user_id FROM users WHERE id = user_id))
  WITH CHECK (auth.uid() = (SELECT auth_user_id FROM users WHERE id = user_id));

-- 4. postsテーブル（タイムライン投稿）Phase2用に先行作成
CREATE TABLE IF NOT EXISTS posts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES users(id) ON DELETE CASCADE,
  task_log_id     UUID REFERENCES task_logs(id) ON DELETE SET NULL,
  comment         TEXT,
  photo_url       TEXT,
  xp_bonus_applied BOOLEAN DEFAULT FALSE,
  likes_count     INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_user_id    ON posts(user_id);

ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Posts are publicly readable"
  ON posts FOR SELECT USING (true);

CREATE POLICY IF NOT EXISTS "Users can manage own posts"
  ON posts FOR INSERT
  WITH CHECK (auth.uid() = (SELECT auth_user_id FROM users WHERE id = user_id));

CREATE POLICY IF NOT EXISTS "Users can update own posts"
  ON posts FOR UPDATE
  USING (auth.uid() = (SELECT auth_user_id FROM users WHERE id = user_id));

CREATE POLICY IF NOT EXISTS "Users can delete own posts"
  ON posts FOR DELETE
  USING (auth.uid() = (SELECT auth_user_id FROM users WHERE id = user_id));
