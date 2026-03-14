# Saikou! - 習慣継続アプリ

## プロジェクト概要

毎日の習慣を継続し、フレンドと一緒に目標達成を目指すPWAアプリ。

- **バージョン**: v18.5.0
- **本番URL**: https://gegsmoop.gensparkspace.com/
- **技術スタック**: Pure HTML/CSS/JavaScript + Supabase + Service Worker (PWA)

---

## ✅ 実装済み機能

### コア機能
- ユーザー登録（招待コード制）・ログイン・パスワードリセット
- 毎日のタスク管理（最大3タスク）・チェックボックス
- 今日の確定（コミット）・取り消し（1日1回まで）
- 継続日数（ストリーク）の自動計算・週間ビュー表示
- 次のマイルストーン（5/10/20/30/50/75/100...日）表示

### ⭐ XP / レベルシステム
- **タスク1つ完了 = 3 XP**、**全タスク完了 = 12 XP**（9+ボーナス3）
- **連続日数ボーナス**: 3日=+1, 7日=+2, 14日=+3, 30日=+5, 60日=+8, 100日=+12 XP
- **レベル1〜100**設計（指数曲線: Lv1→2が100XP、Lv99→100が約50,000XP）
- 各レベルに称号名（例: Lv1「はじめの一歩」→ Lv100「LEGEND」）
- **ホーム画面にXPバー**（ゴールドシマーアニメーション）とレベルバッジ表示
- タスクチェック時に +3XP プレビューを即時表示
- **レベルアップ時**: 全画面オーバーレイ、コンフェッティ80個、バイブレーション
- フレンドカードにも相手のレベルバッジを表示

### 演出・アニメーション
- コミット確定時: ゴールドバナー + XPポップアップ浮上アニメーション
- タスクチェック時: ✅アイコン + XPポップアップ + バイブレーション
- レベルアップ: 全画面フルスクリーン演出（3.8秒、タップで閉じる）
- コンフェッティ: 8色60〜80個がランダムに降り注ぐ
- XPバー: シマーアニメーション + スプリングイージング

### フレンド機能
- 招待コードによるフレンド申請・承認・拒否・削除
- フレンドの継続日数ランキング・今日の達成状況表示
- フレンドカードに相手のレベルバッジを表示
- 応援メッセージ送信（5種類から選択）
- フレンド達成通知（Supabase Realtime経由）
- フレンド画面タブ: 👥 フレンド / 🏆 週間 / 👑 全期間 / 🎟️ 招待

### タイムライン
- コミット確定時に自動投稿（`posts` テーブル）
- 全員 / フレンドのみ フィルター切り替え
- いいね機能・写真付き投稿（XP×1.5ボーナス）
- 無限スクロール（10件ずつ追加読み込み）

### その他
- プッシュ通知（Service Worker + Web Push）
- 管理者テストモード（`?admin_test=saikou2026`）
- 管理者ページ（`/admin.html`、パスワード: `saikou-admin-2026`）
- プライバシーポリシー・利用規約

---

## 📋 Supabase RLS 設定（実行済みSQL）

```sql
-- friends
CREATE POLICY "Friends select own" ON friends
  FOR SELECT USING (
    user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())
    OR friend_user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );
```

---

## ⚠️ 未実装・今後の課題

- XPのDB永続化（現在はlocalStorage）
- Stripe課金・IAP対応
- iOS App Store向けネイティブラップ（PWA Builder / Capacitor）
- 管理者ページのセキュリティ強化
- `debug.html` / `next-steps.html` の本番削除
- Supabase Edge Function（日次脱落判定）
- ストリーク継続での特別演出（マイルストーン達成時）

### 通知システム（実装済み）
- 21:00 JST リマインダー通知（Service Worker タイマー）
- フレンド達成時のOS通知（Realtime INSERT検知）
- Web Push購読（バックグラウンド通知対応）
- 通知バッジ（未読カウント、最大9+表示）
- 通知パネル（最大20件表示、既読管理）

### PWA機能（実装済み）
- Service Worker v10.6.0（キャッシュ管理・更新検知・自動リロード）
- manifest.json（スタンドアロン表示対応）
- ホーム画面追加対応（iOS Safari / Android Chrome）

### セキュリティ
- XSSエスケープ（escapeHtml）
- 入力サニタイゼーション（sanitizeInput）
- パスワード強度チェック
- 招待コード形式検証

---

## 📁 主要ファイル

| ファイル | 説明 |
|----------|------|
| `index.html` | メインアプリ（全機能含む単一ファイル） |
| `sw.js` | Service Worker v10.6.0 |
| `manifest.json` | PWAマニフェスト |
| `admin.html` | 管理画面（通知送信・ユーザー管理） |
| `icon-512x512.png` | アプリアイコン |
| `icon-192.png` | バッジ用アイコン |
| `privacy.html` | プライバシーポリシー |
| `terms.html` | 利用規約 |
| `reset-password.html` | パスワードリセットページ |

---

## 🗄️ データモデル（Supabase）

### テーブル一覧

| テーブル | 説明 |
|----------|------|
| `users` | ユーザー情報（display_name, invite_code, invited_count, is_pro等） |
| `tasks` | ユーザーのタスク（最大3件） |
| `daily_status` | 日次達成状況（date, done_count, is_committed, task_1/2/3_done） |
| `friends` | フレンド関係（user_id, friend_user_id, status: pending/approved） |
| `notifications` | 通知（to_user_id, from_user_id, type, message, is_read） |
| `push_subscriptions` | Web Push購読情報（user_id, endpoint, p256dh, auth） |
| `posts` | タイムライン投稿（user_id, task_log_id, comment, photo_url, xp_bonus_applied, likes_count） |
| `user_points` | ポイント残高 |

### posts テーブルスキーマ（実際のカラム）

```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  task_log_id UUID REFERENCES task_logs(id),  -- NULLの場合はコミット投稿
  comment TEXT,
  photo_url TEXT,
  xp_bonus_applied BOOLEAN DEFAULT FALSE,
  likes_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🌐 主要URL・エンドポイント

| パス | 説明 |
|------|------|
| `/` or `/index.html` | メインアプリ |
| `/admin.html` | 管理画面（パスワード: saikou-admin-2026） |
| `/privacy.html` | プライバシーポリシー |
| `/terms.html` | 利用規約 |
| `/reset-password.html` | パスワードリセット |
| `/manifest.json` | PWAマニフェスト |
| `/sw.js` | Service Worker |

---

## 🔧 グローバル定数

```javascript
const MAX_TASKS = 3;          // タスク上限
const MAX_INVITES_FREE = 2;   // 無料プラン招待上限
const MAX_INVITES_PRO  = 10;  // Proプラン招待上限
```

---

## 🐛 バグ修正履歴

### v18.5.0 (2026-03-14)
**本気の部屋削除 / タイムラインバグ修正 / TLタブ削除**

#### 🗑️ 機能削除
- **本気の部屋（Serious Room / majiroom）機能を完全削除**
  - 関連HTML（モーダル・セクション）・JS（loadSeriousRoom, challengeRequest等）・ナビゲーションを全削除
  - `showScreen` からの seriousRoom 参照を除去

#### 🔴 バグ修正
- **タイムライン投稿が表示されないバグ**
  - **根本原因**: `posts` テーブルに存在しないカラム（`post_type`, `task_names`, `xp_earned`）をSELECT/INSERTしていた → Supabase から HTTP 400 エラー返却
  - **SELECT修正**: `loadTimelineScreen` / `loadMoreTimeline2` で存在しないカラムを除去
  - **INSERT修正**: `handleCommit` の投稿INSERTから非存在カラムを除去
  - **表示修正**: `_renderTimelineCard` のコミット投稿判定を `!post.task_log_id` に簡略化

#### 🎨 UI改善
- **フレンド画面TLタブ削除**: 「📰 TL」ボタンを除去、グリッドを 5列 → 4列 に変更
- **`switchFriendsTab` から timeline 参照を除去**

### v18.4.0 以前
（各バージョンのリリースノートを参照）

---

## 📋 次の開発ステップ

1. **クエスト型タスクシステム**（`QUEST_TASK_DESIGN.md` 参照）:
   - タスクタイプ追加（回数型・時間型・実行型）
   - `tasks` テーブルに `task_type`, `target_value`, `unit` カラム追加
   - `task_logs` テーブル新規作成

2. **Stripe連携**:
   - Stripeダッシュボードで Payment Link 作成
   - Stripe Webhook → Supabase Edge Function

3. **Apple Developer Program 承認後**:
   - App Store Connect でアプリ登録・EAS Build

4. **その他**:
   - `debug.html` / `next-steps.html` の本番削除
   - Supabase Edge Function（日次リセット自動化）
