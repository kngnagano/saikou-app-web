# 📱 App Store 公開準備ガイド

## 🎯 目標
Saikou! アプリを Apple App Store で公開する

---

## ✅ 事前準備チェックリスト

### **1. Apple Developer アカウント**
- [ ] Apple Developer Program に登録（$99/年）
- [ ] 登録完了まで1-2日かかる場合があります
- [ ] URL: https://developer.apple.com/programs/

### **2. アプリ素材の準備**
#### **アイコン**
- [x] **1024×1024px** アプリアイコン（PNG、透過なし）
  - 既に作成済み: `icon-512x512.png`（512pxだが、1024pxにリサイズ可能）
  - カラー: 黒金グラデーション、プレミアム感

#### **スクリーンショット（必須）**
以下のサイズで各2枚以上必要：
- [ ] **6.7インチ**（1290×2796px）- iPhone 14 Pro Max
- [ ] **6.5インチ**（1242×2688px）- iPhone 11 Pro Max
- [ ] **5.5インチ**（1242×2208px）- iPhone 8 Plus

**推奨画面:**
1. ホーム画面（継続日数表示）
2. タスク管理画面
3. フレンド画面
4. 本気の部屋（レベル選択）
5. 挑戦中画面（カレンダー、進捗バー）

#### **プロモーション用テキスト**
- [ ] アプリ名: **Saikou!**
- [ ] サブタイトル: 「毎日を最高にする継続習慣アプリ」
- [ ] 説明文（4000文字以内）
- [ ] キーワード（100文字以内）
- [ ] プロモーションテキスト（170文字以内）

#### **法的文書**
- [ ] プライバシーポリシー URL（必須）
- [ ] 利用規約 URL（推奨）
- [ ] サポート URL（必須）

---

## 🛠️ ビルド手順

### **方法1: PWA Builder（推奨、簡単）**

#### **Step 1: PWA Builder でビルド**
1. https://www.pwabuilder.com/ にアクセス
2. **URL を入力**: `https://gegsmoop.gensparkspace.com/`
3. **Start** をクリック
4. **Package for Stores** → **iOS** を選択
5. 以下の設定を確認：
   - **App Name**: Saikou!
   - **Bundle ID**: com.saikou.app（またはあなたのドメイン）
   - **Version**: 1.0.0
6. **Generate Package** をクリック
7. **ダウンロード**（`.zip` ファイル）

#### **Step 2: Xcode で開く**
1. `.zip` ファイルを解凍
2. `.xcodeproj` ファイルをダブルクリック（Xcode で開く）
3. Xcode がない場合：
   - Mac App Store から Xcode をインストール（無料、約15GB）

#### **Step 3: 署名設定**
1. Xcode でプロジェクトを開く
2. **左側のナビゲーター** → プロジェクト名をクリック
3. **Signing & Capabilities** タブを選択
4. **Team** で Apple Developer アカウントを選択
5. **Bundle Identifier** を確認（例: `com.saikou.app`）

#### **Step 4: アーカイブ作成**
1. Xcode メニューバーで **Product** → **Archive**
2. ビルドが完了するまで待つ（5-10分）
3. **Archives** ウィンドウが開く
4. **Distribute App** をクリック
5. **App Store Connect** を選択 → **Next**
6. アップロード完了を待つ

---

### **方法2: Capacitor（より柔軟）**

#### **Step 1: Capacitor をインストール**
```bash
# Node.js が必要（https://nodejs.org/）
npm install @capacitor/core @capacitor/ios @capacitor/cli
```

#### **Step 2: Capacitor プロジェクトを初期化**
```bash
npx cap init
# App name: Saikou!
# App ID: com.saikou.app
```

#### **Step 3: iOS プロジェクトを追加**
```bash
npx cap add ios
```

#### **Step 4: Xcode で開く**
```bash
npx cap open ios
```

#### **Step 5: Xcode でビルド**
- 方法1の Step 3-4 と同じ手順

---

## 📝 App Store Connect 設定

### **Step 1: 新しいアプリを作成**
1. https://appstoreconnect.apple.com/ にログイン
2. **My Apps** → **+** → **New App**
3. 以下を入力：
   - **Platform**: iOS
   - **Name**: Saikou!
   - **Primary Language**: 日本語
   - **Bundle ID**: `com.saikou.app`（Xcode と同じ）
   - **SKU**: `saikou-app-001`（任意の一意な識別子）

### **Step 2: アプリ情報を入力**

#### **App Information**
- **Name**: Saikou!
- **Subtitle**: 毎日を最高にする継続習慣アプリ
- **Category**: 
  - Primary: **Productivity**（生産性）
  - Secondary: **Health & Fitness**（ヘルス＆フィットネス）

#### **Pricing and Availability**
- **Price**: Free（無料）
- **Availability**: すべての国・地域

#### **App Privacy**
1. **Privacy Policy URL**: （要作成）
   - 例: `https://gegsmoop.gensparkspace.com/privacy`
2. **Data Collection**: 以下を選択
   - [ ] ユーザーID
   - [ ] メールアドレス
   - [ ] プロフィール情報
   - [ ] 使用状況データ

### **Step 3: バージョン情報**

#### **1.0.0 - What's New**
```
初回リリース

【主な機能】
• 毎日のタスク管理で継続習慣をサポート
• 継続日数トラッキング
• フレンドと一緒に目標達成
• 本気の挑戦：7日間の挑戦システム
• ポイント制度で達成感をゲーム化

継続は力なり。
Saikou! で毎日を最高にしよう！
```

#### **Description（説明文）**
```
Saikou! は、あなたの継続習慣を全力でサポートする革新的なアプリです。

【特徴】
✓ シンプルなタスク管理
毎日3つのタスクを設定。完了したらチェック。継続日数が自動的にカウントされます。

✓ フレンドシステム
招待コードでフレンドを追加。お互いの継続日数を確認してモチベーションアップ。

✓ 本気の部屋
7日間継続すると解放される特別な挑戦システム。フレンドと一緒に目標達成を目指そう。ポイント制度で達成感をゲーム化。

✓ 美しいデザイン
カフェ風の落ち着いたデザインで、毎日使いたくなるUI。

【こんな人におすすめ】
• 何をやっても3日坊主で終わってしまう
• 習慣化したいけど、一人だと続かない
• フレンドと一緒に目標達成したい
• ゲーム感覚で楽しく継続したい

継続は力なり。
Saikou! で毎日を最高にしよう！
```

#### **Keywords（キーワード）**
```
習慣,継続,タスク,目標,チャレンジ,フレンド,モチベーション,生産性,健康,自己改善
```

#### **Promotional Text（プロモーションテキスト）**
```
🔥 本気の挑戦 機能を追加！フレンドと一緒に7日間の挑戦に挑もう。ポイント制度で達成感をゲーム化。継続は力なり。
```

### **Step 4: スクリーンショットをアップロード**
1. **iPhone 6.7"** セクションに2-10枚アップロード
2. **iPhone 6.5"** セクションに2-10枚アップロード
3. **iPhone 5.5"** セクションに2-10枚アップロード

### **Step 5: ビルドを選択**
1. **Build** セクション
2. Xcode からアップロードしたビルドを選択
3. **Export Compliance**: 暗号化を使用していない場合は **No** を選択

### **Step 6: 審査に提出**
1. すべての情報を確認
2. **Submit for Review** をクリック
3. 審査には通常1-3日かかります

---

## 🧪 テストフライト（オプション）

App Store に提出する前に、TestFlight で事前テストが可能です。

### **Step 1: TestFlight に追加**
1. App Store Connect → **TestFlight**
2. **Internal Testing** または **External Testing** を選択
3. テスターのメールアドレスを追加

### **Step 2: テスターに招待メールが送信される**
- テスターは TestFlight アプリをインストール
- 招待を承認してアプリをテスト

---

## ⚠️ 審査リジェクト対策

### **よくあるリジェクト理由**
1. **プライバシーポリシー不足**: 必ず URL を提供
2. **スクリーンショットが不適切**: 実際のアプリ画面を使用
3. **機能が不完全**: すべての機能が動作することを確認
4. **パフォーマンス問題**: クラッシュやバグがないことを確認

### **対策**
- ✅ すべての機能をテスト
- ✅ iPhone 実機でテスト
- ✅ プライバシーポリシーを明確に記載
- ✅ スクリーンショットは高品質なものを使用

---

## 📊 リリース後の運用

### **アップデート**
1. 新機能を実装
2. バージョン番号を上げる（例: 1.0.0 → 1.1.0）
3. Xcode で再ビルド → アップロード
4. App Store Connect で新バージョンを作成
5. **What's New** に変更内容を記載
6. 審査に提出

### **ユーザーフィードバック**
- App Store のレビューを定期的に確認
- バグ報告に迅速に対応
- 要望をロードマップに反映

---

## 📞 サポート情報

### **Apple Developer サポート**
- URL: https://developer.apple.com/support/
- メール: developer-support@apple.com

### **審査ガイドライン**
- URL: https://developer.apple.com/app-store/review/guidelines/

### **Saikou! サポート**
- Supabase ダッシュボード: https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq
- 本番 URL: https://gegsmoop.gensparkspace.com/

---

## ✅ 公開完了後のチェックリスト

- [ ] App Store でアプリが公開されていることを確認
- [ ] iPhone 実機でダウンロード & テスト
- [ ] SNS で告知
- [ ] ユーザーフィードバックを収集
- [ ] 次のアップデート計画を立てる

---

## 🎉 おめでとうございます！

Saikou! が App Store で公開されたら、多くのユーザーに継続習慣のサポートを届けることができます。

頑張ってください！🚀
