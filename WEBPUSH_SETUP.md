# Web Push 通知（Edge Function）セットアップガイド

## 概要

Edge Function `send-push-notification` を使うと、**アプリを閉じていても**ユーザーに通知が届きます。

```
admin.html で送信ボタンを押す
  ├─ ① notifications テーブルに INSERT（Realtime → アプリ開いている人に即届く）
  └─ ② Edge Function 呼び出し → Web Push → アプリ閉じている人にも届く
```

---

## 対応環境

| 環境 | Web Push |
|---|---|
| Android Chrome | ✅ 対応 |
| Android PWA（ホーム画面追加） | ✅ 完全対応 |
| iPhone PWA（iOS 16.4以降、ホーム画面追加） | ✅ 対応 |
| iPhone Safari（ブラウザのまま） | ❌ iOS制限で不可 |
| Desktop Chrome / Edge | ✅ 対応 |

---

## セットアップ手順

### 前提
- Node.js がインストール済み
- Supabase CLI がインストール済み

---

### STEP 1: VAPID キーを生成

```bash
npx web-push generate-vapid-keys
```

出力例：
```
Public Key:  BFHrxp5q5Amc0snT1FVz...（87文字）
Private Key: abc123xyz...（43文字）
```

⚠️ **生成した公開鍵を `index.html` の `VAPID_PUBLIC_KEY` に設定する**

```javascript
// index.html の 6072 行付近
const VAPID_PUBLIC_KEY = '← ここに公開鍵を貼り付け';
```

---

### STEP 2: Supabase Secrets に登録

```bash
# Supabase にログイン
supabase login

# プロジェクトにリンク
supabase link --project-ref mthfqqqukuvueprdokiq

# Secrets を設定
supabase secrets set VAPID_PUBLIC_KEY=<上で生成した公開鍵>
supabase secrets set VAPID_PRIVATE_KEY=<上で生成した秘密鍵>
supabase secrets set VAPID_SUBJECT=mailto:admin@saikou.app
```

または Supabase Dashboard から設定：
1. Dashboard → **Settings** → **Edge Functions** → **Secrets**
2. `VAPID_PUBLIC_KEY` / `VAPID_PRIVATE_KEY` / `VAPID_SUBJECT` を追加

---

### STEP 3: push_subscriptions テーブルを作成

Supabase **SQL Editor** で実行：

```sql
CREATE TABLE IF NOT EXISTS public.push_subscriptions (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    text NOT NULL UNIQUE,
  endpoint   text NOT NULL,
  p256dh     text NOT NULL,
  auth       text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.push_subscriptions ENABLE ROW LEVEL SECURITY;

-- service_role（Edge Function）がすべての操作を実行できる
CREATE POLICY "service_role_all" ON public.push_subscriptions
  USING (true) WITH CHECK (true);

-- ユーザー自身が自分の購読を管理できる
CREATE POLICY "users_manage_own_subscription" ON public.push_subscriptions
  FOR ALL USING (auth.uid()::text = user_id);
```

---

### STEP 4: Edge Function をデプロイ

```bash
supabase functions deploy send-push-notification
```

デプロイ完了後、`admin.html` をリロードすると：
```
✅ Edge Function 有効 — アプリを閉じていても届きます
```
と表示されます。

---

### STEP 5: アプリで通知を許可する

1. アプリ（`index.html`）を開く
2. **設定タブ** → **「通知を許可する」** をタップ
3. ブラウザの許可ダイアログで **「許可」** をタップ
4. `push_subscriptions` テーブルにレコードが自動保存される

---

### STEP 6: テスト送信

1. `admin.html` を開く
2. **📢 通知送信** タブ
3. 送信対象: **「特定ユーザー（メール）」** → 自分のメール
4. メッセージを入力 → **「📢 送信する」**

---

## ファイル構成

```
edge-functions/
  send-push-notification/
    index.ts          ← メイン（今回作成）
  notify-friend-commit/
    index.ts          ← フレンド達成通知（既存）
```

---

## API 仕様

### エンドポイント
```
POST https://mthfqqqukuvueprdokiq.supabase.co/functions/v1/send-push-notification
```

### リクエスト
```json
{
  "user_ids": ["uuid1", "uuid2"],  // 省略時は全員
  "title": "通知タイトル",
  "body": "通知本文",
  "type": "admin_broadcast",
  "url": "/"
}
```

### レスポンス
```json
{
  "message": "Done",
  "sent": 5,
  "failed": 0,
  "total": 5,
  "expired_removed": 0
}
```

---

## トラブルシューティング

| 症状 | 原因 | 対処 |
|---|---|---|
| `sent: 0, total: 0` | push_subscriptions が空 | アプリで通知許可をONに |
| `VAPID keys not configured` | Secrets 未設定 | STEP 2 を実行 |
| `expired_removed: N` | 古い購読が削除された | 正常動作（ユーザーが再許可すると復活） |
| iPhone に届かない | PWA でないか iOS 16.4 未満 | ホーム画面に追加してから許可 |
