-- ポイント減算関数
-- Version: 1.0
-- 実装日: 2026-02-22

-- ポイント減算関数（残高がマイナスにならないように制御）
CREATE OR REPLACE FUNCTION decrement_user_points(p_user_id UUID, p_amount INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE user_points
  SET 
    balance = GREATEST(0, balance - p_amount),
    updated_at = NOW()
  WHERE user_id = p_user_id;
  
  -- レコードが存在しない場合は作成
  IF NOT FOUND THEN
    INSERT INTO user_points (user_id, balance)
    VALUES (p_user_id, GREATEST(0, 500 - p_amount));
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ポイント加算関数
CREATE OR REPLACE FUNCTION increment_user_points(p_user_id UUID, p_amount INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE user_points
  SET 
    balance = balance + p_amount,
    updated_at = NOW()
  WHERE user_id = p_user_id;
  
  -- レコードが存在しない場合は作成
  IF NOT FOUND THEN
    INSERT INTO user_points (user_id, balance)
    VALUES (p_user_id, 500 + p_amount);
  END IF;
END;
$$ LANGUAGE plpgsql;

-- 完了
-- 実行手順:
-- 1. Supabase SQL Editor を開く: https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/sql
-- 2. このSQLをコピー＆ペースト
-- 3. 「RUN」をクリック
-- 4. 成功メッセージを確認
