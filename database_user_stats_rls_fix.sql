-- ===================================================
-- user_stats RLS ポリシー修正 (v13.0.0) ★ 最終版
-- ===================================================
-- 変更点 (v13):
--   user_stats.user_id = auth.uid() に統一
--   （= Supabase Auth UUID を直接 user_id として保存）
--
-- 理由:
--   RLS ポリシーは auth.uid() = user_id で判定する。
--   v12 では users.id（カスタムUUID）を使っており、
--   JOIN ポリシーが必要だったが、複雑で障害が多かった。
--   v13 では auth.uid() を user_id として直接使うことで
--   最もシンプルかつ確実な実装にした。
-- ===================================================

-- ============================================
-- 1. テーブル再定義（auth.uid() を PK にする）
-- ============================================
-- ※ 既存テーブルがある場合: 外部キー制約を変更する
-- ※ 既存データがある場合: 手動でデータ移行が必要

-- 既存テーブルを削除して再作成（データが少ない初期段階での推奨）
-- WARNING: 既存データが消えます。必要な場合は手動でバックアップを。
DROP TABLE IF EXISTS public.user_stats CASCADE;

CREATE TABLE public.user_stats (
  user_id    UUID PRIMARY KEY,  -- auth.uid() を直接保存（外部キーなし）
  pow        FLOAT DEFAULT 0,
  kno        FLOAT DEFAULT 0,
  dis        FLOAT DEFAULT 0,
  vit        FLOAT DEFAULT 0,
  soc        FLOAT DEFAULT 0,
  cre        FLOAT DEFAULT 0,
  total_xp   INT DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS user_stats_user_id_idx ON public.user_stats(user_id);

-- ============================================
-- 2. RLS 有効化
-- ============================================
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 3. ポリシー定義（auth.uid() = user_id で判定）
-- ============================================

-- 既存ポリシー削除
DROP POLICY IF EXISTS "user_stats_self"           ON public.user_stats;
DROP POLICY IF EXISTS "user_stats_friends_read"   ON public.user_stats;
DROP POLICY IF EXISTS "user_stats_read_all"       ON public.user_stats;
DROP POLICY IF EXISTS "user_stats_insert_self"    ON public.user_stats;
DROP POLICY IF EXISTS "user_stats_update_self"    ON public.user_stats;
DROP POLICY IF EXISTS "user_stats_delete_self"    ON public.user_stats;

-- SELECT: 全ユーザーが全レコードを読める（フレンドのXP表示用）
CREATE POLICY "user_stats_read_all"
  ON public.user_stats
  FOR SELECT
  USING (true);

-- INSERT: auth.uid() = user_id のみ挿入可能
CREATE POLICY "user_stats_insert_self"
  ON public.user_stats
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- UPDATE: auth.uid() = user_id のみ更新可能
CREATE POLICY "user_stats_update_self"
  ON public.user_stats
  FOR UPDATE
  USING      (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- DELETE: auth.uid() = user_id のみ削除可能
CREATE POLICY "user_stats_delete_self"
  ON public.user_stats
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- 4. user_stones テーブルも同様に修正
-- ============================================
DROP TABLE IF EXISTS public.user_stones CASCADE;

CREATE TABLE public.user_stones (
  user_id                UUID PRIMARY KEY,  -- auth.uid() を直接保存
  amount                 INT DEFAULT 0,
  last_login_bonus_date  TEXT,             -- 'YYYY-MM-DD' 形式
  updated_at             TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.user_stones ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_stones_self"        ON public.user_stones;
DROP POLICY IF EXISTS "user_stones_read_all"    ON public.user_stones;
DROP POLICY IF EXISTS "user_stones_insert_self" ON public.user_stones;
DROP POLICY IF EXISTS "user_stones_update_self" ON public.user_stones;
DROP POLICY IF EXISTS "user_stones_delete_self" ON public.user_stones;

CREATE POLICY "user_stones_read_all"
  ON public.user_stones FOR SELECT USING (true);

CREATE POLICY "user_stones_insert_self"
  ON public.user_stones FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "user_stones_update_self"
  ON public.user_stones FOR UPDATE
  USING      (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "user_stones_delete_self"
  ON public.user_stones FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- 5. 確認クエリ
-- ============================================
SELECT schemaname, tablename, policyname, roles, cmd
FROM pg_policies
WHERE tablename IN ('user_stats', 'user_stones')
ORDER BY tablename, policyname;
