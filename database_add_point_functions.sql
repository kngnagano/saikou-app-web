-- ========================================
-- 【修正】ポイント減算関数を作成
-- ========================================

-- 1. decrement_user_points 関数を作成
CREATE OR REPLACE FUNCTION decrement_user_points(
  p_user_id UUID,
  p_amount INTEGER
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE user_points
  SET balance = balance - p_amount,
      updated_at = NOW()
  WHERE user_id = p_user_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User points record not found for user_id: %', p_user_id;
  END IF;
  
  -- 残高がマイナスにならないようチェック
  IF (SELECT balance FROM user_points WHERE user_id = p_user_id) < 0 THEN
    RAISE EXCEPTION 'Insufficient points for user_id: %', p_user_id;
  END IF;
END;
$$;

-- 2. increment_user_points 関数も確認（既に存在する場合はスキップ）
CREATE OR REPLACE FUNCTION increment_user_points(
  p_user_id UUID,
  p_amount INTEGER
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE user_points
  SET balance = balance + p_amount,
      updated_at = NOW()
  WHERE user_id = p_user_id;
  
  IF NOT FOUND THEN
    INSERT INTO user_points (user_id, balance, created_at, updated_at)
    VALUES (p_user_id, GREATEST(p_amount, 0), NOW(), NOW());
  END IF;
END;
$$;

-- 3. 確認（既存の関数を確認）
SELECT 
  proname AS "関数名",
  prokind AS "種類",
  proargnames AS "引数名"
FROM pg_proc
WHERE proname IN ('increment_user_points', 'decrement_user_points')
ORDER BY proname;
