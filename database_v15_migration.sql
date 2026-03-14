-- ============================================================
-- Saikou! v15 DBマイグレーション
-- 目的: XPを「能力値合計」から「タスク完了による累計獲得XP」に変更
-- ============================================================
-- 実行手順:
--   1. Supabase Dashboard → SQL Editor を開く
--   2. 以下の SQL を貼り付けて「Run」をクリック
-- ============================================================

-- ① user_stats に level・display_name カラムを追加
ALTER TABLE public.user_stats
  ADD COLUMN IF NOT EXISTS level        INTEGER DEFAULT 1,
  ADD COLUMN IF NOT EXISTS display_name TEXT;

-- ② daily_status に xp_gained カラムを追加（未追加の場合）
ALTER TABLE public.daily_status
  ADD COLUMN IF NOT EXISTS xp_gained INTEGER DEFAULT 0;

-- ③ 既存の total_xp を daily_status の xp_gained 合計から再計算して更新
--    （これで過去の分も正確な累計XPに修正される）
UPDATE public.user_stats us
SET
  total_xp = COALESCE((
    SELECT SUM(
      CASE
        WHEN ds.xp_gained IS NOT NULL AND ds.xp_gained > 0 THEN ds.xp_gained
        -- xp_gained未保存分はdone_count×7+全完了ボーナス3で推計
        ELSE (ds.done_count * 7 + CASE WHEN ds.done_count = 3 THEN 3 ELSE 0 END)
      END
    )
    FROM public.daily_status ds
    -- user_statsのuser_id = auth.uid()、daily_statusのuser_id = users.id なので JOIN
    JOIN public.users u ON u.id = ds.user_id
    WHERE u.auth_user_id = us.user_id
      AND ds.is_committed = true
  ), 0),
  updated_at = NOW()
WHERE TRUE;

-- ④ level を total_xp から計算して更新
--    （XPテーブル: Lv1→2=20XP、1.075倍ずつ。簡易計算でLv近似値を設定）
--    正確なレベルはアプリ側の calcLevel() が担当するが、DB確認用に設定
UPDATE public.user_stats
SET level = CASE
  WHEN total_xp < 20   THEN 1
  WHEN total_xp < 42   THEN 2
  WHEN total_xp < 65   THEN 3
  WHEN total_xp < 91   THEN 4
  WHEN total_xp < 118  THEN 5
  WHEN total_xp < 148  THEN 6
  WHEN total_xp < 180  THEN 7
  WHEN total_xp < 214  THEN 8
  WHEN total_xp < 250  THEN 9
  WHEN total_xp < 289  THEN 10
  WHEN total_xp < 331  THEN 11
  WHEN total_xp < 376  THEN 12
  WHEN total_xp < 424  THEN 13
  WHEN total_xp < 476  THEN 14
  WHEN total_xp < 532  THEN 15
  WHEN total_xp < 591  THEN 16
  WHEN total_xp < 654  THEN 17
  WHEN total_xp < 721  THEN 18
  WHEN total_xp < 793  THEN 19
  WHEN total_xp < 869  THEN 20
  WHEN total_xp < 1200 THEN 25
  WHEN total_xp < 1700 THEN 30
  WHEN total_xp < 2300 THEN 35
  WHEN total_xp < 3100 THEN 40
  WHEN total_xp < 4100 THEN 45
  WHEN total_xp < 5300 THEN 50
  WHEN total_xp < 6700 THEN 55
  WHEN total_xp < 8400 THEN 60
  ELSE 65
END
WHERE TRUE;

-- ⑤ display_name を users テーブルから同期
UPDATE public.user_stats us
SET display_name = u.display_name
FROM public.users u
WHERE u.auth_user_id = us.user_id
  AND us.display_name IS NULL;

-- ⑥ 確認クエリ（結果を見て正しいか確認してください）
SELECT
  us.user_id,
  us.display_name,
  us.total_xp,
  us.level,
  us.pow, us.kno, us.dis, us.vit, us.soc, us.cre,
  us.updated_at
FROM public.user_stats us
ORDER BY us.total_xp DESC;
