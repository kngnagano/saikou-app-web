# キャッシュクリア手順

## 問題
Service Workerが古いバージョンのファイルをキャッシュしているため、修正が反映されていません。

## 解決方法

### Chrome / Edge の場合
1. **F12** キーを押してデベロッパーツールを開く
2. **Application** タブをクリック
3. 左側の **Service Workers** をクリック
4. 登録されているService Workerの **Unregister** をクリック
5. 次に **Clear storage** をクリック
6. **Clear site data** ボタンをクリック
7. ページをリロード（**Ctrl + Shift + R** または **Cmd + Shift + R**）

### Safari (iOS) の場合
1. 設定アプリを開く
2. **Safari** をタップ
3. **履歴とWebサイトデータを消去** をタップ
4. 確認画面で **履歴とデータを消去** をタップ
5. Safariを開いてページにアクセス

### Firefox の場合
1. **F12** キーを押してデベロッパーツールを開く
2. **ストレージ** タブをクリック
3. **Service Workers** を右クリック → **登録解除**
4. **キャッシュストレージ** を右クリック → **すべて削除**
5. ページをリロード（**Ctrl + Shift + R**）

## または、シンプルな方法

### シークレットモード / プライベートブラウジング
1. **Ctrl + Shift + N** (Chrome) または **Ctrl + Shift + P** (Firefox)
2. シークレットウィンドウでアプリを開く
3. Service Workerなしで最新版が表示されます

## 確認方法
正常に修正が反映された場合、以下のメッセージがコンソールに表示されます：
- ✅ `Supabase initialized successfully`
- ✅ `Setup button found`
- ✅ `Login button found`
- ❌ **エラーなし**

## 開発者向け: 自動更新コード
Service Workerに自動更新機能を追加済み。
新しいバージョンが検出されると、ユーザーに更新を促します。
