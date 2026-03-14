# Supabase RLS（Row Level Security）設定ガイド

## 🔒 概要

Row Level Security（RLS）は、Supabaseのデータベースレベルでのアクセス制御機能です。  
これにより、**ユーザーは自分のデータのみアクセス可能**となり、他のユーザーのデータを見たり編集したりできなくなります。

## ⚠️ 重要性

RLSを設定しないと：
- 他のユーザーのタスク、習慣データが閲覧・編集可能
- 招待コード、メールアドレス等の個人情報が漏洩
- 不正なデータ操作が可能

**本番環境では必須の設定です！**

---

## 📋 設定手順

### 1. Supabaseダッシュボードにアクセス

https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/editor

左メニュー: **Database** → **Tables**

---

### 2. `users` テーブルのRLS設定

#### 2.1 RLSを有効化

1. `users` テーブルをクリック
2. 右上の **⚙️ (設定アイコン)** → **Enable RLS**

#### 2.2 ポリシーを作成

**Policy 1: ユーザーは自分のレコードのみ閲覧可能**

```sql
CREATE POLICY "Users can view own data"
ON users
FOR SELECT
USING (auth.uid() = auth_user_id);
```

- **Name**: `Users can view own data`
- **Command**: `SELECT`
- **Target roles**: `authenticated`
- **Using expression**:
  ```sql
  auth.uid() = auth_user_id
  ```

**Policy 2: ユーザーは自分のレコードのみ更新可能**

```sql
CREATE POLICY "Users can update own data"
ON users
FOR UPDATE
USING (auth.uid() = auth_user_id)
WITH CHECK (auth.uid() = auth_user_id);
```

- **Name**: `Users can update own data`
- **Command**: `UPDATE`
- **Target roles**: `authenticated`
- **Using expression**:
  ```sql
  auth.uid() = auth_user_id
  ```
- **With check expression**:
  ```sql
  auth.uid() = auth_user_id
  ```

**Policy 3: 新規ユーザー登録時のみ挿入可能**

```sql
CREATE POLICY "Anyone can insert on signup"
ON users
FOR INSERT
WITH CHECK (true);
```

- **Name**: `Anyone can insert on signup`
- **Command**: `INSERT`
- **Target roles**: `authenticated`
- **With check expression**: `true`

**⚠️ 注意**: 招待コード検証のため、一部の閲覧ポリシーを調整する必要があります：

```sql
CREATE POLICY "Users can view others for invite code"
ON users
FOR SELECT
USING (true);
```

または、招待コード検証用の専用カラムを作成し、そのカラムのみ全員が閲覧可能にする設計も推奨されます。

---

### 3. `tasks` テーブルのRLS設定

#### 3.1 RLSを有効化

1. `tasks` テーブルをクリック
2. 右上の **⚙️ (設定アイコン)** → **Enable RLS**

#### 3.2 ポリシーを作成

**Policy 1: ユーザーは自分のタスクのみ閲覧可能**

```sql
CREATE POLICY "Users can view own tasks"
ON tasks
FOR SELECT
USING (
  user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
);
```

- **Name**: `Users can view own tasks`
- **Command**: `SELECT`
- **Target roles**: `authenticated`
- **Using expression**:
  ```sql
  user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
  ```

**Policy 2: ユーザーは自分のタスクのみ挿入可能**

```sql
CREATE POLICY "Users can insert own tasks"
ON tasks
FOR INSERT
WITH CHECK (
  user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
);
```

**Policy 3: ユーザーは自分のタスクのみ更新可能**

```sql
CREATE POLICY "Users can update own tasks"
ON tasks
FOR UPDATE
USING (
  user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
)
WITH CHECK (
  user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
);
```

**Policy 4: ユーザーは自分のタスクのみ削除可能**

```sql
CREATE POLICY "Users can delete own tasks"
ON tasks
FOR DELETE
USING (
  user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
);
```

---

### 4. `daily_status` テーブルのRLS設定

#### 4.1 RLSを有効化

1. `daily_status` テーブルをクリック
2. 右上の **⚙️ (設定アイコン)** → **Enable RLS**

#### 4.2 ポリシーを作成

**Policy 1: ユーザーは自分の履歴のみ閲覧可能**

```sql
CREATE POLICY "Users can view own status"
ON daily_status
FOR SELECT
USING (
  user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
);
```

**Policy 2: ユーザーは自分の履歴のみ挿入可能**

```sql
CREATE POLICY "Users can insert own status"
ON daily_status
FOR INSERT
WITH CHECK (
  user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
);
```

**Policy 3: ユーザーは自分の履歴のみ更新可能**

```sql
CREATE POLICY "Users can update own status"
ON daily_status
FOR UPDATE
USING (
  user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
)
WITH CHECK (
  user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
);
```

---

### 5. `friends` テーブルのRLS設定

#### 5.1 RLSを有効化

1. `friends` テーブルをクリック
2. 右上の **⚙️ (設定アイコン)** → **Enable RLS**

#### 5.2 ポリシーを作成

**Policy 1: ユーザーは自分の友達関係のみ閲覧可能**

```sql
CREATE POLICY "Users can view own friends"
ON friends
FOR SELECT
USING (
  user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
  OR
  friend_user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
);
```

**Policy 2: ユーザーは友達関係を挿入可能**

```sql
CREATE POLICY "Users can insert friends"
ON friends
FOR INSERT
WITH CHECK (
  user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
  OR
  friend_user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
);
```

**Policy 3: ユーザーは自分の友達関係のみ削除可能**

```sql
CREATE POLICY "Users can delete own friends"
ON friends
FOR DELETE
USING (
  user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
  OR
  friend_user_id IN (
    SELECT id FROM users WHERE auth_user_id = auth.uid()
  )
);
```

---

## 🧪 テスト方法

### 1. SQL Editorでテスト

Supabaseの **SQL Editor** で以下を実行:

```sql
-- 現在のユーザー情報を確認
SELECT auth.uid();

-- 自分のタスクが見えることを確認
SELECT * FROM tasks;

-- 他のユーザーのタスクが見えないことを確認（user_idを変更して試す）
SELECT * FROM tasks WHERE user_id = 'other-user-id';
```

### 2. アプリ上でテスト

1. 2つのアカウントを作成（User A、User B）
2. User Aでログインし、タスクを作成
3. User Bでログインし、User Aのタスクが見えないことを確認
4. User Bが自分のタスクのみ見えることを確認

---

## ⚠️ トラブルシューティング

### エラー: `new row violates row-level security policy`

**原因**: RLSポリシーが厳しすぎる

**解決策**:
- ポリシーの条件を再確認
- `auth.uid()` と `auth_user_id` の紐付けが正しいか確認
- INSERT時は `WITH CHECK` 条件を確認

### エラー: `permission denied for table`

**原因**: RLSが有効だが、ポリシーが設定されていない

**解決策**:
- 各操作（SELECT、INSERT、UPDATE、DELETE）に対応するポリシーを作成

### 友達のデータが見えない

**原因**: 友達閲覧用のポリシーが不足

**解決策**:
- `friends` テーブルで友達関係を確認し、友達のタスクを閲覧できるポリシーを追加:

```sql
CREATE POLICY "Users can view friends tasks"
ON tasks
FOR SELECT
USING (
  user_id IN (
    SELECT friend_user_id FROM friends 
    WHERE user_id IN (
      SELECT id FROM users WHERE auth_user_id = auth.uid()
    )
  )
);
```

---

## 📚 補足情報

### Supabase Auth Helper関数

- `auth.uid()`: 現在ログインしているユーザーのAuth UUID
- `auth.role()`: ユーザーのロール（`authenticated`, `anon` 等）
- `auth.email()`: ユーザーのメールアドレス

### ベストプラクティス

1. **最小権限の原則**: 必要最小限のアクセス権のみ付与
2. **テスト**: 本番デプロイ前に必ずRLSをテスト
3. **ログ確認**: Supabase LogsでRLS違反を監視
4. **定期監査**: ポリシーを定期的に見直し

---

## 🔗 関連ドキュメント

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL RLS Documentation](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Supabase Auth Helpers](https://supabase.com/docs/guides/auth/auth-helpers)

---

## ✅ チェックリスト

- [ ] `users` テーブルのRLSを有効化
- [ ] `users` テーブルのポリシーを作成（閲覧・更新・挿入）
- [ ] `tasks` テーブルのRLSを有効化
- [ ] `tasks` テーブルのポリシーを作成（全操作）
- [ ] `daily_status` テーブルのRLSを有効化
- [ ] `daily_status` テーブルのポリシーを作成（全操作）
- [ ] `friends` テーブルのRLSを有効化
- [ ] `friends` テーブルのポリシーを作成（全操作）
- [ ] 2つのアカウントでテスト完了
- [ ] 友達データの閲覧テスト完了
- [ ] エラーログの確認

**すべてチェックが完了したら、本番環境への RLS 適用は完了です！🎉**
