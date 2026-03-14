-- ============================================================
-- 全ユーザーのXP・能力値・レベルを完全リセット
-- Saikou! v15.0 - 検証開始前リセット
-- 実行場所: Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. user_stats: 全能力値・XP・レベルを0にリセット
UPDATE public.user_stats
SET
  pow        = 0,
  kno        = 0,
  dis        = 0,
  vit        = 0,
  soc        = 0,
  cre        = 0,
  total_xp   = 0,
  level      = 1,
  updated_at = NOW();

-- 2. daily_status: xp_gained を0にリセット（履歴は残す）
UPDATE public.daily_status
SET xp_gained = 0
WHERE xp_gained IS NOT NULL AND xp_gained > 0;

-- 確認クエリ（実行後に確認用）
SELECT user_id, display_name, pow, kno, dis, vit, soc, cre, total_xp, level
FROM public.user_stats
ORDER BY updated_at DESC;
