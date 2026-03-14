-- ===================================================
-- 💎 アルタストーンシステム DB セットアップ
-- Saikou! v12.0.0
-- ===================================================
-- 実行順序:
-- 1. user_stones テーブル作成
-- 2. friend_achievements テーブル作成
-- 3. user_stats の user_id を auth UID に統一する修正
-- ===================================================

-- ─────────────────────────────────────────
-- 1. user_stones テーブル
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_stones (
  user_id                UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  amount                 INT  DEFAULT 0 CHECK (amount >= 0),
  last_login_bonus_date  DATE DEFAULT NULL,  -- ログインボーナス重複防止
  updated_at             TIMESTAMPTZ DEFAULT NOW()
);

-- RLS有効化
ALTER TABLE public.user_stones ENABLE ROW LEVEL SECURITY;

-- 既存ポリシー削除（べき等）
DROP POLICY IF EXISTS "stones_read_self"   ON public.user_stones;
DROP POLICY IF EXISTS "stones_insert_self" ON public.user_stones;
DROP POLICY IF EXISTS "stones_update_self" ON public.user_stones;
DROP POLICY IF EXISTS "stones_delete_self" ON public.user_stones;

-- RLSポリシー: users.auth_user_id = auth.uid() で照合
CREATE POLICY "stones_read_self"
  ON public.user_stones FOR SELECT
  USING (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

CREATE POLICY "stones_insert_self"
  ON public.user_stones FOR INSERT
  WITH CHECK (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

CREATE POLICY "stones_update_self"
  ON public.user_stones FOR UPDATE
  USING (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()))
  WITH CHECK (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

CREATE POLICY "stones_delete_self"
  ON public.user_stones FOR DELETE
  USING (user_id IN (SELECT id FROM public.users WHERE auth_user_id = auth.uid()));

-- ─────────────────────────────────────────
-- 2. friend_achievements テーブル
--    フレンドが達成した記録（30分ボーナス判定用）
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.friend_achievements (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  -- 通知先ユーザー (自分) の auth UID
  friend_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  -- 達成したフレンドの auth UID
  achieved_at    TIMESTAMPTZ DEFAULT NOW(),
  streak         INT DEFAULT 0
);

CREATE INDEX IF NOT EXISTS fa_user_idx    ON public.friend_achievements(user_id);
CREATE INDEX IF NOT EXISTS fa_friend_idx  ON public.friend_achievements(friend_user_id);
CREATE INDEX IF NOT EXISTS fa_achieved_idx ON public.friend_achievements(achieved_at);

ALTER TABLE public.friend_achievements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "fa_read_self"   ON public.friend_achievements;
DROP POLICY IF EXISTS "fa_insert_self" ON public.friend_achievements;

-- 自分宛ての通知を読む
CREATE POLICY "fa_read_self"
  ON public.friend_achievements FOR SELECT
  USING (user_id = auth.uid());

-- 誰でも挿入可能（フレンドが自分の通知テーブルに書き込む）
CREATE POLICY "fa_insert_any"
  ON public.friend_achievements FOR INSERT
  WITH CHECK (true);

-- ─────────────────────────────────────────
-- 3. user_stats の user_id を auth UID に統一
--    (既存データがある場合の移行)
-- ─────────────────────────────────────────
-- ※ 既存の user_stats.user_id が users.id (カスタムUUID) の場合
-- 以下で auth.users.id に変換します

-- まず既存テーブルが auth UID で動いているか確認:
-- SELECT user_id FROM user_stats LIMIT 5;
-- → auth.users テーブルに同じ UUID があれば auth UID 運用
-- → なければ以下の移行を実行

-- 移行SQL (慎重に実行してください):
/*
-- user_statsのuser_idをauth_user_idに変換
UPDATE public.user_stats us
SET user_id = u.auth_user_id
FROM public.users u
WHERE us.user_id = u.id
  AND u.auth_user_id IS NOT NULL
  AND us.user_id != u.auth_user_id;
*/

-- ─────────────────────────────────────────
-- 4. daily_status に recovered_by_stone 列追加
-- ─────────────────────────────────────────
ALTER TABLE public.daily_status
  ADD COLUMN IF NOT EXISTS recovered_by_stone BOOLEAN DEFAULT FALSE;

-- ─────────────────────────────────────────
-- 確認クエリ
-- ─────────────────────────────────────────
SELECT 'user_stones' as table_name, count(*) as rows FROM public.user_stones
UNION ALL
SELECT 'friend_achievements', count(*) FROM public.friend_achievements;
