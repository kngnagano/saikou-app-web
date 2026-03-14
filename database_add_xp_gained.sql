-- ============================================================
-- Saikou! v14.1 — daily_status に xp_gained カラムを追加
-- ============================================================
-- 目的:
--   週間ランキングで「その週に実際に獲得したXP」を正確に集計するため、
--   コミット時に取得したXPを daily_status.xp_gained に保存する。
--
-- 実行手順:
--   1. Supabase Dashboard → SQL Editor を開く
--   2. 以下の SQL を貼り付けて「Run」をクリック
--   3. エラーが出なければ完了
-- ============================================================

-- xp_gained カラムを追加（既に存在する場合はスキップ）
ALTER TABLE public.daily_status
  ADD COLUMN IF NOT EXISTS xp_gained INTEGER DEFAULT 0;

-- 確認クエリ（実行後に列が追加されたか確認）
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'daily_status'
ORDER BY ordinal_position;
