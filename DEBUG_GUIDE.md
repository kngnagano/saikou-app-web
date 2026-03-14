# デバッグガイド

## 🐛 確認手順

### Publishして再デプロイ後：

1. **ブラウザのコンソールを開く**（F12キー）
2. タスクにチェックを入れる
3. 「今日を確定」をクリック
4. **コンソールに表示される内容を確認**：

```
renderTasks called, todayDone: [true, false, true], isCommitted: true
```

このように表示されれば、`todayDone`は正しく保持されています。

---

## 🔍 期待される動作

### 確定ボタンをクリックした時：

1. ✅ `saveDailyStatus(true)` でSupabaseに保存
2. ✅ `currentUser.history` に今日のレコードを追加
3. ✅ `renderWeeklyView()` で週次ビュー更新 → **マークが表示される**
4. ✅ `renderTasks()` でタスク再描画 → **チェックマークが残る**
5. ✅ Successバナーが表示される
6. ✅ 3秒後にバナーが消える

---

## 🎯 確認ポイント

### 週次ビューが更新されない場合：
- `currentUser.history` が正しく更新されているか確認
- コンソールで以下を実行：
  ```javascript
  console.log(currentUser.history);
  ```
- 今日の日付のレコードが `is_committed: true` になっているか確認

### チェックマークが消える場合：
- コンソールで `todayDone` の値を確認
- `isCommitted` が `true` になっているか確認
- `renderTasks()` が呼ばれた時の値をログで確認

### バナーが一瞬で消える場合：
- `setTimeout` が正しく動作しているか確認
- ブラウザのキャッシュをクリア（Ctrl+Shift+R）

---

## 📝 コンソールで確認するコマンド

```javascript
// 現在の状態を確認
console.log('todayDone:', todayDone);
console.log('isCommitted:', isCommitted);
console.log('currentUser.history:', currentUser.history);

// 今日のレコードを確認
const today = new Date().toISOString().split('T')[0];
const todayRecord = currentUser.history.find(h => h.date === today);
console.log('Today record:', todayRecord);
```

---

結果を教えてください！
