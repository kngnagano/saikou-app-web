# Saikou! v18.5.0 リリースノート

**リリース日**: 2026-03-14
**Service Worker**: v10.6.0
**重要度**: 🟡 MINOR UPDATE（機能削除 + バグ修正）

---

## 📋 変更サマリー

| # | 種別 | 内容 |
|---|------|------|
| 1 | 🗑️ 削除 | 本気の部屋（Serious Room / majiroom）機能を完全削除 |
| 2 | 🔴 バグ修正 | タイムライン投稿が表示されないバグを修正 |
| 3 | 🎨 UI | フレンド画面の「TL」タブを削除 |

---

## 1. 🗑️ 本気の部屋機能削除

### 削除した理由
機能が未完成かつ DB テーブル（`majiroom_*`）依存の設計が複雑なため、
現フェーズでは不要と判断。Stripe決済・脱落自動判定など未実装部分が多く、
ユーザーへ中途半端な状態で提供するリスクがあった。

### 削除した範囲
**HTML:**
- 本気の部屋セクション（`#seriousRoomScreen`）
- 覚悟宣言モーダル（`#declareModal`）
- 参加確認モーダル（`#confirmParticipationModal`）
- ナビゲーションボタン（`#navSeriousRoom`）

**JavaScript:**
- `loadSeriousRoom()` / `_renderSeriousRoom()`
- `submitDeclaration()` / `showDeclareModal()`
- `loadChallengeRequests()` / `renderIncomingChallengeRequests()`
- `approveChallengeRequest()` / `rejectChallengeRequest()` / `cancelChallengeRequest()`
- `processBuddyApproval()` / `_adminEnterRoom()`
- `SERIOUS_ROOM_LEVELS` 定数

**その他:**
- `showScreen()` からの seriousRoom 分岐を除去
- `switchFriendsTab()` からの timeline 参照を除去

---

## 2. 🔴 タイムライン投稿バグ修正

### 症状
- コミット（今日を確定）を実行してもタイムラインに投稿が表示されない
- タイムライン画面を開くと「読み込みに失敗しました」と表示される

### 根本原因
`posts` テーブルに **存在しないカラム** を SELECT / INSERT していた。

| カラム | 実態 |
|--------|------|
| `post_type` | ❌ DBに存在しない |
| `task_names` | ❌ DBに存在しない |
| `xp_earned` | ❌ DBに存在しない |

Supabase（PostgREST）は存在しないカラムをクエリすると HTTP 400 を返す。
SELECT失敗 → `throw error` → catch ブロックでエラー表示。
INSERT失敗 → Supabase はエラーオブジェクトを返すがJSは throw しない → 投稿が**サイレントに保存失敗**。

### 修正内容

**SELECT修正** (`loadTimelineScreen` / `loadMoreTimeline2`):
```javascript
// Before
.select('id, comment, photo_url, xp_bonus_applied, likes_count, created_at, user_id, task_log_id, post_type, task_names, xp_earned')

// After
.select('id, comment, photo_url, xp_bonus_applied, likes_count, created_at, user_id, task_log_id')
```

**INSERT修正** (`handleCommit`):
```javascript
// Before
await supabase.from('posts').insert({
  user_id: currentUser.id, task_log_id: null,
  comment: commitComment, photo_url: commitPhotoUrl || null,
  xp_bonus_applied: !!hasCommitPhoto, likes_count: 0,
  post_type: 'commit',        // ← 存在しない
  task_names: doneTaskNames,  // ← 存在しない
  xp_earned: totalXpGained   // ← 存在しない
});

// After
await supabase.from('posts').insert({
  user_id: currentUser.id, task_log_id: null,
  comment: commitComment, photo_url: commitPhotoUrl || null,
  xp_bonus_applied: !!hasCommitPhoto, likes_count: 0
});
```

**表示修正** (`_renderTimelineCard`):
- コミット投稿の判定: `post.post_type === 'commit'` → `!post.task_log_id` に変更
- タスク名・XP表示（存在しないデータに依存）を削除し、「今日を確定！⚡」表示に簡略化

---

## 3. 🎨 フレンド画面 TL タブ削除

### 変更内容
フレンド画面タブから「📰 TL（タイムライン）」ボタンを削除。

タイムラインはナビゲーションの独立タブ（📰）から直接アクセス可能なため、
フレンド画面内のタブとして持つ必要がなかった。

```
Before: 👥フレンド | 📰TL | 🏆週間 | 👑全期間 | 🎟️招待  (5列グリッド)
After:  👥フレンド | 🏆週間 | 👑全期間 | 🎟️招待              (4列グリッド)
```

---

## 🔄 マイグレーション不要

今回の変更は**フロントエンドのみ**の修正です。
- DB テーブル追加・変更なし
- Supabase RLS変更なし
- Edge Function変更なし

ただし、Supabase の `majiroom_*` テーブルは残っています。
将来的に不要と確定したら `database_serious_room.sql` のDROP文で削除可能です。

---

## 📦 デプロイ手順

1. `index.html` を本番にアップロード
2. `sw.js` を本番にアップロード（キャッシュ名が `saikou-v10.6.0` に変わるため既存ユーザーのSWが自動更新される）
3. ブラウザのキャッシュクリアを推奨（特に開発環境）
