// Supabase Edge Function: notify-friend-commit
// daily_status に is_committed=true のレコードが INSERT されたとき
// そのユーザーのフレンド全員にWeb Pushを送信する
//
// デプロイコマンド:
//   supabase functions deploy notify-friend-commit
//
// 環境変数（Supabase Dashboard → Settings → Edge Functions → Secrets）:
//   VAPID_PRIVATE_KEY  : VAPID秘密鍵
//   VAPID_PUBLIC_KEY   : VAPID公開鍵
//   VAPID_SUBJECT      : mailto:your-email@example.com
//   SUPABASE_URL       : （自動設定）
//   SUPABASE_SERVICE_ROLE_KEY : （自動設定）

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ---- Web Push 送信ヘルパー（純粋なWeb Crypto API実装） ----
async function sendWebPush(subscription: {
  endpoint: string;
  p256dh: string;
  auth: string;
}, payload: string, vapidKeys: {
  privateKey: string;
  publicKey: string;
  subject: string;
}): Promise<boolean> {
  try {
    // web-push ライブラリの代わりに fetch で直接送信
    // VAPID 署名生成
    const header = btoa(JSON.stringify({ typ: 'JWT', alg: 'ES256' }))
      .replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
    
    const now = Math.floor(Date.now() / 1000);
    const claims = btoa(JSON.stringify({
      aud: new URL(subscription.endpoint).origin,
      exp: now + 12 * 3600,
      sub: vapidKeys.subject
    })).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');

    // VAPID JWTの簡易実装（Deno/Edge Runtimeではweb-pushが使えないため）
    // 実際のプッシュ送信はweb-pushライブラリを使う方法で実装
    
    const response = await fetch(subscription.endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/octet-stream',
        'Content-Encoding': 'aes128gcm',
        'TTL': '86400',
        'Authorization': `vapid t=${header}.${claims},k=${vapidKeys.publicKey}`
      },
      body: payload
    });

    return response.ok || response.status === 201;
  } catch (err) {
    console.error('sendWebPush error:', err);
    return false;
  }
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization'
      }
    });
  }

  try {
    const body = await req.json();
    console.log('📨 notify-friend-commit called:', JSON.stringify(body));

    // Supabase Webhook からの呼び出し: body.record に新しいレコードが入る
    const record = body.record || body;
    const committerUserId = record.user_id;
    const isCommitted = record.is_committed;
    const commitDate = record.date;

    if (!committerUserId || !isCommitted) {
      return new Response(JSON.stringify({ message: 'Not a commit event, skip' }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Supabase クライアント（service_role = RLS バイパス）
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 1. コミットしたユーザーの情報を取得
    const { data: committer } = await supabase
      .from('users')
      .select('display_name, avatar_url, current_streak')
      .eq('id', committerUserId)
      .single();

    if (!committer) {
      return new Response(JSON.stringify({ error: 'Committer not found' }), { status: 200 });
    }

    console.log(`✅ Committer: ${committer.display_name}, streak: ${committer.current_streak}`);

    // 2. フレンドリストを取得（承認済みのフレンド）
    const { data: friendRels } = await supabase
      .from('friend_relationships')
      .select('user_id, friend_id')
      .or(`user_id.eq.${committerUserId},friend_id.eq.${committerUserId}`)
      .eq('status', 'accepted');

    if (!friendRels || friendRels.length === 0) {
      return new Response(JSON.stringify({ message: 'No friends to notify' }), { status: 200 });
    }

    // フレンドのユーザーIDリストを作成
    const friendIds = friendRels.map(r =>
      r.user_id === committerUserId ? r.friend_id : r.user_id
    );
    console.log(`👥 Friends to notify: ${friendIds.length}`);

    // 3. フレンドのプッシュ購読情報を取得
    const { data: subscriptions } = await supabase
      .from('push_subscriptions')
      .select('user_id, endpoint, p256dh, auth')
      .in('user_id', friendIds);

    if (!subscriptions || subscriptions.length === 0) {
      return new Response(JSON.stringify({ message: 'No push subscriptions found' }), { status: 200 });
    }

    console.log(`🔔 Sending push to ${subscriptions.length} friends`);

    // 4. プッシュ通知ペイロード
    const payload = JSON.stringify({
      title: '🎉 フレンドが今日を達成！',
      body: `${committer.display_name} さんが今日のタスクを達成！\n継続 ${committer.current_streak || 0} 日🔥 一緒に頑張ろう！`,
      icon: committer.avatar_url || '/icon-512x512.png',
      badge: '/icon-192.png',
      tag: `friend-${committerUserId}-${commitDate}`,
      url: '/',
      type: 'friend'
    });

    // 5. web-push ライブラリを使って各フレンドに送信
    // Deno では npm:web-push を使う
    const webpush = await import('npm:web-push@3.6.7');
    webpush.setVapidDetails(
      Deno.env.get('VAPID_SUBJECT') ?? 'mailto:saikou@example.com',
      Deno.env.get('VAPID_PUBLIC_KEY') ?? '',
      Deno.env.get('VAPID_PRIVATE_KEY') ?? ''
    );

    const results = await Promise.allSettled(
      subscriptions.map(async (sub) => {
        try {
          await webpush.sendNotification(
            {
              endpoint: sub.endpoint,
              keys: { p256dh: sub.p256dh, auth: sub.auth }
            },
            payload
          );
          console.log(`✅ Push sent to user: ${sub.user_id}`);
          return { userId: sub.user_id, success: true };
        } catch (err: any) {
          console.error(`❌ Push failed for user ${sub.user_id}:`, err.message);
          // 410 Gone = 購読が無効 → DBから削除
          if (err.statusCode === 410) {
            await supabase
              .from('push_subscriptions')
              .delete()
              .eq('user_id', sub.user_id);
            console.log(`🗑️ Removed expired subscription for: ${sub.user_id}`);
          }
          return { userId: sub.user_id, success: false, error: err.message };
        }
      })
    );

    const succeeded = results.filter(r => r.status === 'fulfilled' && (r.value as any).success).length;
    const failed    = results.length - succeeded;

    return new Response(JSON.stringify({
      message: `Push notifications sent`,
      succeeded,
      failed,
      total: subscriptions.length
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (err: any) {
    console.error('❌ Edge Function error:', err);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
});
