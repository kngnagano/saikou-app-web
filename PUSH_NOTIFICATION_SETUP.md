# バックグラウンドプッシュ通知 設定手順
## フレンド達成通知（画面を閉じていても届く）

---

## 仕組み

```
フレンドが「今日を確定」
    ↓
Supabase Database Webhook が発火
    ↓
Edge Function (notify-friend-commit) が実行
    ↓
フレンドのプッシュ購読情報をDBから取得
    ↓
Web Push API でプッシュ送信
    ↓
フレンドのデバイス（iPhone/Android）に通知届く
（アプリが閉じていても動作 ✅）
```

---

## Step 1: push_subscriptions テーブルを作成

Supabase SQL Editor で `database_push_subscriptions.sql` を実行：
https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/sql

```sql
CREATE TABLE IF NOT EXISTS push_subscriptions (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  endpoint   TEXT NOT NULL,
  p256dh     TEXT NOT NULL,
  auth       TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "push_sub_insert" ON push_subscriptions FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "push_sub_select" ON push_subscriptions FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "push_sub_update" ON push_subscriptions FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "push_sub_delete" ON push_subscriptions FOR DELETE TO authenticated USING (auth.uid() = user_id);
```

---

## Step 2: VAPID キーペアを生成

以下のコマンドを実行（Node.js が必要）：
```bash
npx web-push generate-vapid-keys
```

出力例：
```
Public Key: BEl62iUYgUivxIkv69yViEuiBIa-Ib9-SkvMeAtA3LFgDzkrxZJjSgSnfckjBJuBkr3qBUYIHBQFLXYp5Nksh8U
Private Key: your_private_key_here
```

⚠️ **公開鍵を index.html の `VAPID_PUBLIC_KEY` 変数に設定してください**（現在はダミー値）

---

## Step 3: Supabase Edge Function をデプロイ

```bash
# Supabase CLI をインストール
npm install -g supabase

# ログイン
supabase login

# プロジェクトリンク
supabase link --project-ref mthfqqqukuvueprdokiq

# Edge Function をデプロイ
supabase functions deploy notify-friend-commit
```

---

## Step 4: Edge Function に環境変数を設定

Supabase Dashboard → Settings → Edge Functions → Secrets：
https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/settings/functions

| 変数名 | 値 |
|--------|-----|
| `VAPID_PUBLIC_KEY`  | Step 2 で生成した公開鍵 |
| `VAPID_PRIVATE_KEY` | Step 2 で生成した秘密鍵 |
| `VAPID_SUBJECT`     | `mailto:your-email@example.com` |

---

## Step 5: Database Webhook を設定

Supabase Dashboard → Database → Webhooks：
https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/database/hooks

「Create a new hook」をクリック：
- **Name**: `notify_friend_commit`
- **Table**: `daily_status`
- **Events**: `INSERT`
- **Type**: `Supabase Edge Functions`
- **Edge Function**: `notify-friend-commit`

---

## Step 6: テスト

1. アプリを開いてログイン
2. 設定 → 「🔔 プッシュ通知」 → 「通知を許可する」
3. コンソールで `✅ [Push] Subscription saved to DB` を確認
4. Supabase の `push_subscriptions` テーブルにレコードがあることを確認
5. **アプリを完全に閉じる**（スワイプで終了）
6. 別のデバイス/アカウントでログインして「今日を確定」
7. Step 5 のフレンドのデバイスに通知が届く

---

## トラブルシューティング

### iPhone Safari で通知が来ない
- iPhone は **iOS 16.4以降** + **ホーム画面に追加（PWA）** が必要
- 設定 → Safari → 詳細 → Web インスペクタ ON
- Develop → iPhone → Console でエラーを確認

### 「PushManager not supported」
- HTTPS 環境でのみ動作（HTTP では使えない）
- 本番URL（https://gegsmoop.gensparkspace.com/）でテスト

### サブスクリプションが保存されない
- Supabase に `push_subscriptions` テーブルが存在するか確認
- RLS ポリシーが4つ揃っているか確認
- コンソールで `❌ [Push] Failed to save subscription:` を確認

---

## 注意事項

- iOS Safari の Web Push は **PWA（ホーム画面に追加）のみ** 対応
- 通常のSafariブラウザではバックグラウンドプッシュは届かない
- App Store 公開後は PWA としてインストールされるため問題なし
