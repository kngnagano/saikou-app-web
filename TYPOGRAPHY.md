# 🎨 Saikou! タイポグラフィシステム

## 📖 フォントファミリー

### 1. **Noto Sans JP** - メインフォント
- **用途**: 本文、見出し、ボタン
- **特徴**: 読みやすく現代的、日本語に最適化
- **ウェイト**: 300, 400, 500, 600, 700, 800, 900
- **適用箇所**:
  - 全ての見出し（h1, h2, h3）
  - ボタンテキスト
  - メインテキスト
  - ナビゲーション

```css
body {
  font-family: 'Noto Sans JP', -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  letter-spacing: 0.025em;
  line-height: 1.6;
}
```

### 2. **Poppins** - 数字・アクセント
- **用途**: 継続日数、目標カウンター、招待コード
- **特徴**: クリーンでモダン、タビュラー数字対応
- **ウェイト**: 300, 400, 500, 600, 700, 800, 900
- **適用箇所**:
  - `.display-number` クラス
  - 継続日数表示
  - 次の目標カウント
  - 招待コード表示

```css
.display-number {
  font-family: 'Poppins', 'DM Sans', sans-serif;
  font-weight: 800;
  letter-spacing: -0.03em;
  font-feature-settings: "tnum"; /* タビュラー数字 */
}
```

### 3. **DM Sans** - 小テキスト・ラベル
- **用途**: ラベル、プレースホルダー、補足テキスト
- **特徴**: 軽量で読みやすい、小さいサイズでも視認性が高い
- **ウェイト**: 300, 400, 500, 600, 700
- **適用箇所**:
  - `.label-text` クラス
  - 入力フィールドのプレースホルダー
  - 小さい補足テキスト

```css
.label-text {
  font-family: 'DM Sans', 'Noto Sans JP', sans-serif;
  font-weight: 500;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  font-size: 0.75rem;
  opacity: 0.7;
}
```

## 🎯 タイポグラフィスケール

### 見出し
```css
/* 超大見出し - メインタイトル */
h1.main-title {
  font-size: 2rem;
  font-weight: 900;
  letter-spacing: 0.12em;
  line-height: 1.2;
}

/* 大見出し - セクションタイトル */
h2 {
  font-size: 1.5rem;
  font-weight: 800;
  letter-spacing: 0.1em;
  line-height: 1.3;
}

/* 中見出し - カードタイトル */
h3 {
  font-size: 1.125rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  line-height: 1.4;
}
```

### 数字表示
```css
/* 継続日数 - 最大サイズ */
.streak-count {
  font-size: 4rem; /* 64px */
  font-weight: 800;
  letter-spacing: -0.03em;
}

/* 目標カウント - 中サイズ */
.goal-count {
  font-size: 1.75rem; /* 28px */
  font-weight: 700;
  letter-spacing: -0.02em;
}

/* プロフィール数字 - 小サイズ */
.profile-number {
  font-size: 2rem; /* 32px */
  font-weight: 700;
  letter-spacing: -0.01em;
}
```

### ボタン・アクション
```css
/* プライマリボタン */
.btn-primary {
  font-size: 1.125rem;
  font-weight: 700;
  letter-spacing: 0.08em;
}

/* セカンダリボタン */
.btn-secondary {
  font-size: 0.875rem;
  font-weight: 600;
  letter-spacing: 0.05em;
}

/* ナビゲーション */
.nav-item {
  font-size: 0.9rem;
  font-weight: 600;
  letter-spacing: 0.06em;
}
```

### ラベル・補足
```css
/* ラベル（継続日数・次の目標まで） */
.label-text {
  font-size: 0.75rem; /* 12px */
  font-weight: 500;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  opacity: 0.7;
}

/* 補足テキスト */
.text-xs {
  font-size: 0.75rem;
  font-weight: 400;
  letter-spacing: 0.03em;
}
```

## 🎨 文字間隔（Letter Spacing）ガイド

| 要素 | Letter Spacing | 目的 |
|------|----------------|------|
| 見出し（H1） | 0.12em | 力強さと視認性 |
| 見出し（H2） | 0.1em | バランスと読みやすさ |
| 見出し（H3） | 0.08em | 自然な間隔 |
| ボタン | 0.08em | クリック感とプレミアム感 |
| ナビゲーション | 0.06em | 統一感 |
| ラベル | 0.1em（大文字） | 視認性向上 |
| 本文 | 0.025em | 読みやすさ |
| 数字 | -0.03em | タイトさと正確性 |

## 💡 使用例

### ホーム画面
```html
<!-- タイトル -->
<h1 style="font-weight: 900; letter-spacing: 0.12em;">Saikou!</h1>

<!-- ラベル -->
<p class="label-text" style="font-family: 'DM Sans', 'Noto Sans JP', sans-serif; 
   font-size: 0.875rem; font-weight: 500; letter-spacing: 0.1em; 
   text-transform: uppercase; opacity: 0.7;">
  継続日数
</p>

<!-- 継続日数 -->
<p class="display-number" style="font-size: 4rem;">42日</p>
```

### ボタン
```html
<!-- 今日を確定ボタン -->
<button class="btn-primary" style="font-size: 1.25rem; 
   font-weight: 700; letter-spacing: 0.1em;">
  今日を確定
</button>
```

### 招待コード
```html
<p class="display-number" style="font-family: 'Poppins', 'DM Sans', monospace; 
   letter-spacing: 0.15em;">SAIKOU-2026</p>
```

## 📊 レスポンシブ対応

### モバイル（〜640px）
- 見出しサイズを10-15%縮小
- Letter spacingは維持（視認性優先）

### タブレット（641px〜）
- 標準サイズを使用
- 最大幅768pxで最適化

### デスクトップ（769px〜）
- タブレットサイズを維持
- カードは中央配置

## 🎯 ベストプラクティス

### ✅ すべきこと
1. **数字にはPoppins**: 継続日数・目標カウントなど
2. **日本語にはNoto Sans JP**: 見出し・本文すべて
3. **ラベルにはDM Sans**: 小さいテキストとプレースホルダー
4. **Letter spacingを活用**: 視認性とプレミアム感
5. **font-feature-settings**: 数字には`"tnum"`を指定

### ❌ 避けるべきこと
1. **3つ以上のフォント**: 統一感が失われる
2. **極端なLetter spacing**: 読みにくくなる
3. **細すぎるウェイト**: モバイルで視認性低下
4. **過度なイタリック**: 日本語では不自然

## 🔧 実装チェックリスト

- [x] Google Fonts CDN読み込み（Noto Sans JP, Poppins, DM Sans）
- [x] CSSカスタムプロパティで基本スタイル定義
- [x] `.display-number`クラスでPoppins適用
- [x] `.label-text`クラスでDM Sans適用
- [x] すべての見出しにNoto Sans JP + 適切なウェイト
- [x] ボタンにfont-weight: 700 + letter-spacing
- [x] 入力フィールドにDM Sans + Noto Sans JP
- [x] ナビゲーションに統一フォント設定

## 📦 CDN読み込み

```html
<!-- Google Fonts - Premium Typography -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@300;400;500;600;700;800;900&family=Poppins:wght@300;400;500;600;700;800;900&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;0,9..40,700;1,9..40,400&display=swap" rel="stylesheet">
```

---

**ステータス**: ✅ 完全実装済み
**最終更新**: 2026-02-16
**デザインコンセプト**: カフェ風・モダン・ミニマル
