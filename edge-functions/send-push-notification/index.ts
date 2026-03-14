// Supabase Edge Function: send-push-notification
// admin.html から呼び出し、指定ユーザーへ Web Push を送信する
//
// デプロイ:
//   supabase functions deploy send-push-notification
//
// 環境変数（Supabase Dashboard → Settings → Edge Functions → Secrets）:
//   VAPID_PRIVATE_KEY  : VAPID秘密鍵（supabase functions secrets set で登録）
//   VAPID_PUBLIC_KEY   : VAPID公開鍵
//   VAPID_SUBJECT      : mailto:your-email@example.com
//   SUPABASE_URL       : （自動設定）
//   SUPABASE_SERVICE_ROLE_KEY : （自動設定）
//
// リクエスト例:
//   POST /functions/v1/send-push-notification
//   Headers: { Authorization: "Bearer <anon_key>" }
//   Body: {
//     "user_ids": ["uuid1", "uuid2"],   // 特定ユーザー（省略時は全員）
//     "title": "通知タイトル",
//     "body": "通知本文",
//     "type": "admin_broadcast",
//     "url": "/"
//   }

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ---- CORS ヘッダー ----
const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

// ---- Web Push 送信（web-push npm パッケージ使用） ----
async function sendWebPush(
  sub: { endpoint: string; p256dh: string; auth: string },
  payload: string,
  vapid: { publicKey: string; privateKey: string; subject: string }
): Promise<{ ok: boolean; expired?: boolean; error?: string }> {
  try {
    const webpush = await import('npm:web-push@3.6.7');
    webpush.setVapidDetails(vapid.subject, vapid.publicKey, vapid.privateKey);
    await webpush.sendNotification(
      { endpoint: sub.endpoint, keys: { p256dh: sub.p256dh, auth: sub.auth } },
      payload
    );
    return { ok: true };
  } catch (err: any) {
    // 410 Gone または 404 = 購読期限切れ → DB から削除すべき
    const expired = err?.statusCode === 410 || err?.statusCode === 404;
    return { ok: false, expired, error: err?.message ?? String(err) };
  }
}

// ---- メイン ----
Deno.serve(async (req) => {
  // プリフライト
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: CORS });
  }
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405, headers: CORS });
  }

  try {
    // ---- 環境変数 ----
    const SUPABASE_URL  = Deno.env.get('SUPABASE_URL') ?? '';
    const SERVICE_KEY   = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const VAPID_PUB     = Deno.env.get('VAPID_PUBLIC_KEY') ?? '';
    const VAPID_PRIV    = Deno.env.get('VAPID_PRIVATE_KEY') ?? '';
    const VAPID_SUB     = Deno.env.get('VAPID_SUBJECT') ?? 'mailto:admin@saikou.app';

    if (!VAPID_PUB || !VAPID_PRIV) {
      console.error('❌ VAPID keys not set');
      return new Response(
        JSON.stringify({ error: 'VAPID keys not configured. Set VAPID_PUBLIC_KEY and VAPID_PRIVATE_KEY in Edge Function Secrets.' }),
        { status: 500, headers: { ...CORS, 'Content-Type': 'application/json' } }
      );
    }

    // ---- リクエスト body ----
    const body = await req.json();
    const {
      user_ids,        // string[] | undefined（undefined = 全員）
      title = '🔔 Saikou!',
      body: msgBody = '通知が届きました',
      type  = 'admin_broadcast',
      url   = '/',
      icon  = '/icon-512x512.png',
      badge = '/icon-192.png',
    } = body;

    console.log('📨 send-push-notification called, type:', type, 'targets:', user_ids?.length ?? 'ALL');

    // ---- Supabase（service_role = RLS バイパス） ----
    const sb = createClient(SUPABASE_URL, SERVICE_KEY);

    // ---- プッシュ購読を取得 ----
    let query = sb
      .from('push_subscriptions')
      .select('user_id, endpoint, p256dh, auth');

    if (user_ids && user_ids.length > 0) {
      query = query.in('user_id', user_ids);
    }

    const { data: subs, error: subErr } = await query;

    if (subErr) {
      console.error('❌ push_subscriptions fetch error:', subErr.message);
      return new Response(
        JSON.stringify({ error: subErr.message }),
        { status: 500, headers: { ...CORS, 'Content-Type': 'application/json' } }
      );
    }

    if (!subs || subs.length === 0) {
      console.log('⚠️ No push subscriptions found for targets');
      return new Response(
        JSON.stringify({ message: 'No subscriptions found', sent: 0, total: 0 }),
        { status: 200, headers: { ...CORS, 'Content-Type': 'application/json' } }
      );
    }

    console.log(`🔔 Sending Web Push to ${subs.length} subscribers`);

    // ---- ペイロード ----
    const payload = JSON.stringify({ title, body: msgBody, icon, badge, tag: type + '-' + Date.now(), url, type });

    const vapid = { publicKey: VAPID_PUB, privateKey: VAPID_PRIV, subject: VAPID_SUB };

    // ---- 並列送信（最大20件同時） ----
    const CONCURRENCY = 20;
    let sent = 0, failed = 0;
    const expiredEndpoints: string[] = [];

    for (let i = 0; i < subs.length; i += CONCURRENCY) {
      const batch = subs.slice(i, i + CONCURRENCY);
      const results = await Promise.allSettled(
        batch.map(sub => sendWebPush(sub, payload, vapid))
      );
      results.forEach((r, idx) => {
        const sub = batch[idx];
        if (r.status === 'fulfilled') {
          if (r.value.ok) {
            sent++;
            console.log(`✅ Sent to ${sub.user_id}`);
          } else {
            failed++;
            console.warn(`❌ Failed for ${sub.user_id}: ${r.value.error}`);
            if (r.value.expired) expiredEndpoints.push(sub.endpoint);
          }
        } else {
          failed++;
          console.error(`❌ Rejected for ${sub.user_id}:`, r.reason);
        }
      });
    }

    // ---- 期限切れ購読を DB から削除 ----
    if (expiredEndpoints.length > 0) {
      const { error: delErr } = await sb
        .from('push_subscriptions')
        .delete()
        .in('endpoint', expiredEndpoints);
      if (delErr) console.warn('⚠️ Failed to delete expired subs:', delErr.message);
      else console.log(`🗑️ Deleted ${expiredEndpoints.length} expired subscriptions`);
    }

    return new Response(
      JSON.stringify({
        message: 'Done',
        sent,
        failed,
        total: subs.length,
        expired_removed: expiredEndpoints.length,
      }),
      { status: 200, headers: { ...CORS, 'Content-Type': 'application/json' } }
    );

  } catch (err: any) {
    console.error('❌ Edge Function error:', err);
    return new Response(
      JSON.stringify({ error: err.message ?? String(err) }),
      { status: 500, headers: { ...CORS, 'Content-Type': 'application/json' } }
    );
  }
});
