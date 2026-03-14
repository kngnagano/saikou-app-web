-- ================================================================
-- Saikou! v15.6.0 データ修正SQL
-- 目的: 個別能力値の合計 = total_xp に統一する
-- ================================================================

-- ① 個別能力値が全て0 & total_xp > 0 のユーザーを配分で修正
--    配分比率: POW:KNO:DIS:VIT:SOC:CRE = 20:15:25:15:15:10
UPDATE public.user_stats
SET
  pow = FLOOR(total_xp * 20 / 100),
  kno = FLOOR(total_xp * 15 / 100),
  dis = total_xp
        - FLOOR(total_xp * 20 / 100)  -- pow
        - FLOOR(total_xp * 15 / 100)  -- kno
        - FLOOR(total_xp * 15 / 100)  -- vit
        - FLOOR(total_xp * 15 / 100)  -- soc
        - FLOOR(total_xp * 10 / 100), -- cre
  vit = FLOOR(total_xp * 15 / 100),
  soc = FLOOR(total_xp * 15 / 100),
  cre = FLOOR(total_xp * 10 / 100),
  updated_at = NOW()
WHERE
  (pow = 0 AND kno = 0 AND dis = 0 AND vit = 0 AND soc = 0 AND cre = 0)
  AND total_xp > 0;

-- ② 能力値合計 ≠ total_xp のユーザーを修正（能力値合計を正とする）
UPDATE public.user_stats
SET
  total_xp   = (pow + kno + dis + vit + soc + cre),
  level      = 1, -- calcLevel は JS 側で計算。仮で1にしておく
  updated_at = NOW()
WHERE
  (pow + kno + dis + vit + soc + cre) > 0
  AND (pow + kno + dis + vit + soc + cre) <> total_xp;

-- ③ 確認クエリ
SELECT
  user_id,
  pow, kno, dis, vit, soc, cre,
  (pow + kno + dis + vit + soc + cre) AS stat_sum,
  total_xp,
  CASE WHEN (pow + kno + dis + vit + soc + cre) = total_xp THEN '✅ 一致' ELSE '❌ 不一致' END AS check_result
FROM public.user_stats
ORDER BY total_xp DESC;
