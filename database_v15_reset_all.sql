-- ============================================================
-- Saikou! v15 — 全ユーザー XP・能力値・ストーン 完全リセット
-- 今日から検証開始のため、全データをゼロにリセットする
-- ============================================================
-- ⚠️ 警告: このSQLを実行するとすべてのユーザーの
--   XP・レベル・能力値・ストーン・週間XP記録が消えます。
--   元に戻せません。実行前に必ずバックアップを取ってください。
-- ============================================================
-- 実行手順:
--   1. Supabase Dashboard → SQL Editor
--   2. 以下を貼り付けて「Run」
-- ============================================================

-- ① user_stats を全ユーザーリセット（XP・能力値・レベルをゼロに）
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

-- ② user_stones を全ユーザーリセット（ストーンゼロに）
UPDATE public.user_stones
SET
  amount                = 0,
  last_login_bonus_date = NULL,
  updated_at            = NOW();

-- ③ daily_status の xp_gained をリセット（過去データはis_committed等は残す）
UPDATE public.daily_status
SET xp_gained = 0;

-- ④ リセット後の確認クエリ
SELECT
  us.display_name,
  us.total_xp,
  us.level,
  us.pow, us.kno, us.dis, us.vit, us.soc, us.cre,
  us.updated_at
FROM public.user_stats us
ORDER BY us.updated_at DESC;
