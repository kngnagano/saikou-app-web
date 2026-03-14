-- ========================================
-- push_subscriptions テーブル作成
-- Web Push 購読情報を保存する
-- ========================================

CREATE TABLE IF NOT EXISTS push_subscriptions (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  endpoint   TEXT NOT NULL,
  p256dh     TEXT NOT NULL,
  auth       TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS 有効化
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

-- 自分のサブスクリプションのみ読み書き可
CREATE POLICY "push_sub_insert" ON push_subscriptions
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "push_sub_select" ON push_subscriptions
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "push_sub_update" ON push_subscriptions
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "push_sub_delete" ON push_subscriptions
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- Edge Function から全ユーザーの購読情報を読む必要があるため
-- service_role キーを使う Edge Function には RLS を通過させる
-- (Edge Function は service_role で実行されるため自動的にバイパスされる)
