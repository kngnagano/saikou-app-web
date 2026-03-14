# 🚨 重要: プッシュ通知機能について

## ⚠️ 制限事項

プッシュ通知機能（PWA Push Notifications）は、**静的HTMLファイルだけでは実装できません**。

### 必要な要素

1. **Service Worker** (sw.js)
2. **サーバーサイド通知送信システム**
3. **VAPID鍵ペア**
4. **HTTPSドメイン**

---

## 🔧 実装に必要なもの

### 1. Service Worker (sw.js)
```javascript
// sw.js - ルートディレクトリに配置
self.addEventListener('push', function(event) {
  const data = event.data ? event.data.json() : {};
  const title = data.title || 'Saikou!';
  const options = {
    body: data.body || '通知が届きました',
    icon: '/icon-192.png',
    badge: '/icon-192.png',
    tag: 'saikou-notification',
    requireInteraction: false
  };
  event.waitUntil(
    self.registration.showNotification(title, options)
  );
});

self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  event.waitUntil(
    clients.openWindow('/')
  );
});
```

### 2. サーバーサイド通知システム
**Supabase Edge Functions**または**Cloudflare Workers**が必要

```typescript
// Supabase Edge Function 例
import { createClient } from '@supabase/supabase-js'
import webpush from 'web-push'

// VAPID鍵設定
webpush.setVapIDDetails(
  'mailto:your-email@example.com',
  process.env.VAPID_PUBLIC_KEY,
  process.env.VAPID_PRIVATE_KEY
);

export async function sendNotification(userId: string, message: string) {
  const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
  
  // ユーザーのプッシュサブスクリプションを取得
  const { data: subscriptions } = await supabase
    .from('push_subscriptions')
    .select('*')
    .eq('user_id', userId);
  
  // 各デバイスに通知を送信
  for (const sub of subscriptions) {
    await webpush.sendNotification(sub.subscription, JSON.stringify({
      title: 'Saikou!',
      body: message
    }));
  }
}
```

### 3. データベーステーブル
```sql
-- push_subscriptions テーブル
CREATE TABLE push_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  subscription JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, subscription)
);
```

---

## 📱 代替案: 簡易通知システム

### 実装可能な機能

現在の静的HTMLアプリで実装できる通知機能：

#### 1. **アプリ内通知**
- フレンドがタスクを達成したら、次回アプリを開いた時にバッジ表示
- 「新着3件」のような表示

#### 2. **ブラウザ通知API** (限定的)
- ユーザーがアプリを開いている間のみ動作
- バックグラウンドでは動作しない

```javascript
// ブラウザ通知の例（アプリ起動中のみ）
if ('Notification' in window && Notification.permission === 'granted') {
  new Notification('Saikou!', {
    body: '太郎さんがタスクを達成しました！',
    icon: '/icon-192.png'
  });
}
```

#### 3. **リアルタイム更新**
- Supabase Realtime Subscriptionsを使用
- アプリを開いている間はリアルタイムで更新
- フレンドの達成状況を自動更新

---

## 🎯 推奨実装: リアルタイム更新

### 実装手順

1. **Supabase Realtime有効化**
```javascript
// daily_status テーブルの変更をリアルタイムで監視
const subscription = supabase
  .channel('daily_status_changes')
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'daily_status'
  }, (payload) => {
    // フレンドの達成状況が更新されたら通知
    handleFriendUpdate(payload);
  })
  .subscribe();
```

2. **アプリ内バッジ表示**
```javascript
// 未読通知カウント
function showNotificationBadge(count) {
  const badge = document.getElementById('notificationBadge');
  badge.textContent = count;
  badge.classList.remove('hidden');
}
```

3. **通知リスト画面**
- 「○○さんがタスクを達成しました」
- 「△△さんが5日連続達成！」

---

## 🚀 実装の優先順位

### フェーズ1: アプリ内通知（すぐに実装可能）
- ✅ 通知リスト画面
- ✅ バッジ表示
- ✅ 未読カウント

### フェーズ2: リアルタイム更新（Supabase Realtimeが必要）
- ⚠️ リアルタイムサブスクリプション
- ⚠️ 自動更新

### フェーズ3: プッシュ通知（サーバー必要）
- ❌ Service Worker
- ❌ サーバーサイド通知
- ❌ VAPID鍵

---

## 💡 ユーザーへの提案

プッシュ通知を実装するには、以下のいずれかが必要です：

### オプションA: Supabase Edge Functions を使用
- 月額 $25〜（Proプラン）
- サーバーレスで実装可能
- 完全なプッシュ通知対応

### オプションB: 外部サービスを使用
- Firebase Cloud Messaging (FCM) - 無料
- OneSignal - 無料〜
- Pushover - $5/月

### オプションC: アプリ内通知のみ
- **無料**
- 現在のSupabase無料プランで実装可能
- バックグラウンド通知は不可

---

## 🎯 現在実装済みの代替機能

1. **リアルタイムフレンド状況表示**
   - フレンドタブを開くと最新状態を取得
   - 継続日数、今日の達成状況を表示

2. **フレンド詳細モーダル**
   - タスク一覧と達成状況
   - 週次ビュー

3. **自動更新（予定）**
   - 1分ごとにフレンド状況をチェック
   - バックグラウンドで更新

---

## 📝 結論

**現在の静的HTMLアプリでは、完全なプッシュ通知は実装できません。**

しかし、以下の代替機能は実装可能です：
- ✅ アプリ内通知リスト
- ✅ 未読バッジ
- ✅ リアルタイムフレンド状況表示
- ✅ 定期的な自動更新

これらの機能を実装することで、ユーザー体験を大幅に向上させることができます。

---

**推奨**: まずアプリ内通知システムを実装し、後でプッシュ通知を追加する方向で進めることをお勧めします。
