// Saikou! Service Worker v10.8.0
// v10.8.0: キャッシュ強制更新 (v18.6.0対応)
// v10.7.0: ストーン同期・いいね永続化・レベル表示修正・アイテムモーダル改善 (v18.6.0対応)
// v10.6.0: 本気の部屋機能削除・タイムライン投稿バグ修正 (v18.5.0対応)

const CACHE_NAME  = 'saikou-v10.8.0';
// index.html と sw.js は絶対にキャッシュしない
const NO_CACHE_URLS = ['/index.html', '/', '/sw.js'];
const REMINDER_HOUR = 21; // JST 21:00

// ========== Install ==========
self.addEventListener('install', event => {
  console.log('[SW v10.8] install');
  event.waitUntil(
    // index.html / sw.js はキャッシュしない（常に最新を取得）
    caches.open(CACHE_NAME).then(c =>
      c.addAll(['/manifest.json']).catch(() => {})
    )
  );
  self.skipWaiting();
});

// ========== Activate ==========
self.addEventListener('activate', event => {
  console.log('[SW v10.8] activate');
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
      .then(() => scheduleDailyReminder())
  );
});

// ========== Fetch（ネットワーク優先・Supabase除外） ==========
self.addEventListener('fetch', event => {
  const url = event.request.url;
  if (url.includes('supabase.co') || url.includes('googleapis.com') || event.request.method !== 'GET') return;

  // index.html / sw.js は絶対にキャッシュせず、常にネットワークから取得
  const pathname = new URL(url).pathname;
  if (NO_CACHE_URLS.some(p => pathname === p || pathname === p + '.html')) {
    event.respondWith(fetch(event.request));
    return;
  }

  event.respondWith(
    fetch(event.request)
      .then(res => {
        if (res && res.status === 200) {
          const clone = res.clone();
          caches.open(CACHE_NAME).then(c => c.put(event.request, clone));
        }
        return res;
      })
      .catch(() => caches.match(event.request))
  );
});

// ========== Web Push 受信（サーバーから送られた場合） ==========
self.addEventListener('push', event => {
  console.log('[SW v10] push received');
  let data = {};
  try { data = event.data ? event.data.json() : {}; } catch { data = { body: event.data?.text() }; }

  const title   = data.title || '🔔 Saikou!';
  const options = {
    body:              data.body    || '通知が届きました',
    icon:              data.icon    || '/icon-512x512.png',
    badge:             '/icon-192.png',
    tag:               data.tag     || 'push-' + Date.now(),
    renotify:          true,
    requireInteraction: !!data.requireInteraction,
    vibrate:           data.vibrate || [100, 50, 100],
    data:              { url: data.url || '/' },
    actions:           [{ action: 'open', title: '開く' }]
  };
  event.waitUntil(self.registration.showNotification(title, options));
});

// ========== フロントからのメッセージ ==========
self.addEventListener('message', event => {
  const { type, payload } = event.data || {};
  console.log('[SW v10.8] message:', type);

  switch (type) {
    case 'SKIP_WAITING':
      // 新バージョンのSWを即時適用（index.htmlのupdatefoundハンドラから呼ばれる）
      self.skipWaiting();
      break;
    case 'SCHEDULE_REMINDER':
      scheduleDailyReminder();
      break;
    case 'CANCEL_REMINDER':
      cancelReminder();
      break;
    case 'COMMIT_DONE':
      setCommitted(true);
      break;
    case 'COMMIT_UNDONE':
      setCommitted(false);
      break;
    case 'TEST_NOTIFICATION':
      showNotif('🔔 テスト通知', '通知が正常に動作しています！', 'test-' + Date.now(), false);
      break;
    case 'SHOW_FRIEND_NOT_COMMITTED':
      // フレンドが未達成のとき自分のデバイスに通知
      if (payload && payload.friendName) {
        showNotif(
          '💪 ' + payload.friendName + ' さんが未達成',
          '応援メッセージを送りました！一緒に頑張ろう🔥',
          'friend-not-committed-' + Date.now(),
          false
        );
      }
      break;
    // フロントから「今すぐリマインダーを表示せよ」と指示される場合
    case 'SHOW_REMINDER_NOW':
      showReminderNotification();
      break;
  }
});

// ========== 通知クリック ==========
self.addEventListener('notificationclick', event => {
  event.notification.close();
  if (event.action === 'dismiss') return;
  const url = event.notification.data?.url || '/';
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(list => {
      for (const c of list) {
        if (c.url.includes(self.location.origin) && 'focus' in c) return c.focus();
      }
      return clients.openWindow(url);
    })
  );
});

self.addEventListener('notificationclose', () => {});

// ========== 21:00 リマインダー タイマー ==========
let reminderTimer = null;

function cancelReminder() {
  if (reminderTimer) { clearTimeout(reminderTimer); reminderTimer = null; }
  console.log('[SW v10] reminder cancelled');
}

function scheduleDailyReminder() {
  cancelReminder();

  const now  = new Date();
  // JST = UTC+9
  const jstH = (now.getUTCHours() + 9) % 24;
  const jstM = now.getUTCMinutes();
  const jstS = now.getUTCSeconds();

  // 今日の 21:00 JST まで何ミリ秒か
  let ms = ((REMINDER_HOUR - jstH) * 3600 - jstM * 60 - jstS) * 1000;
  if (ms <= 0) ms += 24 * 60 * 60 * 1000; // 既に過ぎていれば翌日

  const target = new Date(now.getTime() + ms);
  console.log(`[SW v10] ⏰ next reminder: ${target.toISOString()} (${Math.round(ms/60000)}min)`);

  reminderTimer = setTimeout(async () => {
    await fireReminderIfNeeded();
    scheduleDailyReminder(); // 翌日分を予約
  }, ms);
}

async function fireReminderIfNeeded() {
  const committed = await getCommitted();
  console.log('[SW v10] fireReminder committed=', committed);

  if (committed) {
    console.log('[SW v10] ✅ already committed, skip');
    return;
  }

  // 通知許可チェック
  if (self.Notification?.permission !== 'granted') {
    console.log('[SW v10] ❌ no permission');
    return;
  }

  await showReminderNotification();

  // フロントが開いていれば CHECK_FRIEND_COMMIT_STATUS を送る
  try {
    const allClients = await self.clients.matchAll({ type: 'window', includeUncontrolled: false });
    for (const c of allClients) {
      c.postMessage({ type: 'CHECK_FRIEND_COMMIT_STATUS' });
    }
  } catch (e) {
    console.warn('[SW v10] client post error:', e);
  }
}

async function showReminderNotification() {
  try {
    await self.registration.showNotification('⏰ Saikou! リマインダー', {
      body: '今日のタスクをまだ確定していません！\n今すぐ達成しましょう 🔥',
      icon: '/icon-512x512.png',
      badge: '/icon-192.png',
      tag: 'daily-reminder',
      renotify: true,
      requireInteraction: true,
      vibrate: [200, 100, 200, 100, 200],
      data: { url: '/' },
      actions: [
        { action: 'open',    title: '📱 アプリを開く' },
        { action: 'dismiss', title: '後で' }
      ]
    });
    console.log('[SW v10] 🔔 reminder shown');
  } catch (e) {
    console.error('[SW v10] reminder error:', e);
  }
}

// ========== 汎用通知表示 ==========
async function showNotif(title, body, tag, requireInteraction = false) {
  try {
    await self.registration.showNotification(title, {
      body, tag,
      icon: '/icon-512x512.png',
      badge: '/icon-192.png',
      renotify: true,
      requireInteraction,
      vibrate: [100, 50, 100],
      data: { url: '/' }
    });
  } catch (e) {
    console.error('[SW v10] showNotif error:', e);
  }
}

// ========== IndexedDB: committed フラグ管理 ==========
function getTodayJST() {
  const d = new Date(Date.now() + 9 * 3600 * 1000);
  return d.toISOString().slice(0, 10);
}

function openDB() {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open('saikou-sw', 3);
    req.onupgradeneeded = e => {
      const db = e.target.result;
      if (!db.objectStoreNames.contains('state')) {
        db.createObjectStore('state', { keyPath: 'key' });
      }
    };
    req.onsuccess = () => resolve(req.result);
    req.onerror   = () => reject(req.error);
  });
}

async function setCommitted(value) {
  try {
    const db = await openDB();
    const tx = db.transaction('state', 'readwrite');
    tx.objectStore('state').put({ key: `committed_${getTodayJST()}`, value });
    console.log('[SW v10] committed =', value, getTodayJST());
  } catch (e) {
    console.error('[SW v10] setCommitted error:', e);
  }
}

async function getCommitted() {
  try {
    const db = await openDB();
    return new Promise(resolve => {
      const tx  = db.transaction('state', 'readonly');
      const req = tx.objectStore('state').get(`committed_${getTodayJST()}`);
      req.onsuccess = () => resolve(req.result?.value ?? false);
      req.onerror   = () => resolve(false);
    });
  } catch {
    return false;
  }
}
