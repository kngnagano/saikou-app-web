# Saikou! - 追加のSupabase設定

## フレンド機能のためのテーブル追加

以下のSQLをSupabase SQL Editorで実行してください：

```sql
-- Friends table
CREATE TABLE IF NOT EXISTS friends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  friend_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, friend_user_id)
);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_friends_user_id ON friends(user_id);
CREATE INDEX IF NOT EXISTS idx_friends_friend_user_id ON friends(friend_user_id);

-- Enable RLS
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;

-- RLS Policy
CREATE POLICY "Allow all" ON friends FOR ALL USING (true);
```

## 実行手順

1. Supabaseダッシュボードを開く
2. 左側メニューの「SQL Editor」をクリック
3. 上記のSQLをコピー&ペースト
4. 「Run」をクリック

これで、フレンド機能がリアルタイムで動作するようになります！
