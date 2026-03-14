# パスワードポリシー強化ガイド

## 🔐 概要

安全なパスワードポリシーを設定することで、アカウント乗っ取りや不正アクセスを防ぎます。

---

## 📋 現在のパスワードポリシー

### Saikou! アプリ側の実装

#### 最低条件（必須）
- **6文字以上**: Supabaseのデフォルト設定に準拠

#### 推奨条件
- **8文字以上**
- **大文字・小文字・数字を含む**

### JavaScript バリデーション

`validatePassword()` 関数が以下をチェック:

```javascript
function validatePassword(password) {
  if (password.length < 6) {
    return { valid: false, message: 'パスワードは6文字以上で入力してください' };
  }
  
  if (password.length < 8) {
    return { 
      valid: true, 
      weak: true, 
      message: '警告: パスワードは8文字以上を推奨します' 
    };
  }
  
  const hasUpper = /[A-Z]/.test(password);
  const hasLower = /[a-z]/.test(password);
  const hasNumber = /[0-9]/.test(password);
  
  if (!hasUpper || !hasLower || !hasNumber) {
    return { 
      valid: true, 
      weak: true, 
      message: '警告: 大文字・小文字・数字を含むパスワードを推奨します' 
    };
  }
  
  return { valid: true, weak: false, message: '強度: 良好' };
}
```

---

## 🛡️ Supabase 側のパスワードポリシー設定

### 1. Supabaseダッシュボードにアクセス

https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/settings/auth

左メニュー: **Settings** → **Auth**

### 2. パスワード設定を確認

#### 推奨設定:

| 設定項目 | 推奨値 | 説明 |
|---------|--------|------|
| **Minimum password length** | `8` | 最低8文字を要求 |
| **Password strength** | `Weak` ～ `Fair` | 強度チェックレベル（ユーザビリティとセキュリティのバランス） |
| **Require uppercase** | ✅ | 大文字を必須にする（オプション） |
| **Require lowercase** | ✅ | 小文字を必須にする（オプション） |
| **Require numbers** | ✅ | 数字を必須にする（オプション） |
| **Require special characters** | ❌ | 記号を必須にする（初期は無効推奨） |

### 3. 設定例（バランス型）

```
Minimum password length: 8
Password strength: Fair
✅ Require uppercase
✅ Require lowercase
✅ Require numbers
❌ Require special characters
```

この設定により、以下のようなパスワードが必要になります:
- ✅ `Password1`（8文字、大文字・小文字・数字）
- ✅ `Saikou2026`（10文字、大文字・小文字・数字）
- ❌ `password`（小文字のみ）
- ❌ `PASSWORD1`（大文字・数字のみ）

---

## 🔧 より強力なパスワードポリシー（上級編）

本番環境で高いセキュリティが必要な場合:

```
Minimum password length: 12
Password strength: Strong
✅ Require uppercase
✅ Require lowercase
✅ Require numbers
✅ Require special characters (!@#$%^&*)
```

例:
- ✅ `MyP@ssw0rd2026!`（14文字、すべての条件を満たす）
- ✅ `Saikou!Habit#123`（16文字、すべての条件を満たす）

---

## 🚨 パスワードリセット機能

### 現在の実装状況

Saikou! アプリでは、以下のパスワードリセット機能が実装されています:

#### フロントエンド (index.html)

1. **パスワードを忘れた場合** リンク
2. **パスワードリセットモーダル**
   - メールアドレス入力
   - リセットメール送信ボタン

#### JavaScript 関数

```javascript
async function sendPasswordResetEmail() {
  const email = document.getElementById('resetEmailInput').value.trim();
  
  if (!email || !isValidEmail(email)) {
    alert('有効なメールアドレスを入力してください');
    return;
  }
  
  try {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password.html`
    });
    
    if (error) throw error;
    
    alert('パスワードリセット用のメールを送信しました。\nメールをご確認ください。');
    closePasswordResetModal();
    
  } catch (error) {
    console.error('Error sending reset email:', error);
    alert('エラーが発生しました: ' + error.message);
  }
}
```

### Supabase Email Template設定

https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/auth/templates

**Reset Password** テンプレートを編集:

#### 件名:
```
Saikou! パスワードリセットのご案内
```

#### 本文例:
```html
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>パスワードリセット</title>
</head>
<body style="font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.6; color: #333;">
  
  <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
    <h1 style="color: #667eea;">🔑 パスワードリセット</h1>
    
    <p>こんにちは、</p>
    
    <p>Saikou! アカウントのパスワードリセットがリクエストされました。</p>
    
    <p>以下のボタンをクリックして、新しいパスワードを設定してください：</p>
    
    <div style="text-align: center; margin: 30px 0;">
      <a href="{{ .ConfirmationURL }}" 
         style="display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                color: white; padding: 15px 40px; text-decoration: none; border-radius: 25px; 
                font-weight: bold;">
        パスワードをリセット
      </a>
    </div>
    
    <p style="color: #666; font-size: 14px;">
      ⚠️ このリンクは1時間有効です。<br>
      もしパスワードリセットをリクエストしていない場合は、このメールを無視してください。
    </p>
    
    <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
    
    <p style="font-size: 12px; color: #999; text-align: center;">
      © 2026 Saikou Team. All rights reserved.
    </p>
  </div>
  
</body>
</html>
```

---

## 🎯 パスワード強度インジケーターの実装（オプション）

ユーザー体験を向上させるため、リアルタイムでパスワード強度を表示:

### HTML（新規登録フォーム）

```html
<input 
  type="password" 
  id="passwordInput"
  placeholder="パスワード（8文字以上推奨）"
  oninput="showPasswordStrength(this.value)"
/>

<div id="passwordStrength" style="margin-top: 5px; font-size: 0.875rem;">
  <!-- 強度バーがここに表示される -->
</div>
```

### JavaScript

```javascript
function showPasswordStrength(password) {
  const strengthDiv = document.getElementById('passwordStrength');
  
  if (!password) {
    strengthDiv.innerHTML = '';
    return;
  }
  
  const validation = validatePassword(password);
  
  let color, text, width;
  
  if (!validation.valid) {
    color = '#ef4444'; // 赤
    text = '弱い';
    width = '33%';
  } else if (validation.weak) {
    color = '#f59e0b'; // オレンジ
    text = '普通';
    width = '66%';
  } else {
    color = '#10b981'; // 緑
    text = '強い';
    width = '100%';
  }
  
  strengthDiv.innerHTML = `
    <div style="background: #e5e7eb; height: 6px; border-radius: 3px; overflow: hidden;">
      <div style="background: ${color}; height: 100%; width: ${width}; transition: width 0.3s;"></div>
    </div>
    <p style="margin-top: 5px; color: ${color};">
      パスワード強度: <strong>${text}</strong>
    </p>
  `;
}
```

---

## ✅ チェックリスト

### アプリ側
- [x] 最低6文字のバリデーション実装
- [x] 8文字以上を推奨する警告実装
- [x] 大文字・小文字・数字チェック実装
- [x] パスワードリセット機能実装
- [ ] パスワード強度インジケーター実装（オプション）

### Supabase側
- [ ] 最低パスワード長を8文字に設定
- [ ] パスワード強度を "Fair" 以上に設定
- [ ] 大文字・小文字・数字を必須に設定（推奨）
- [ ] パスワードリセットEmailテンプレート設定
- [ ] RLS（Row Level Security）有効化

### テスト
- [ ] 弱いパスワードで登録試行 → エラー確認
- [ ] 強いパスワードで登録成功確認
- [ ] パスワードリセット機能の動作確認
- [ ] メール受信＆リセット完了を確認

---

## 🔗 関連ドキュメント

- [Supabase Auth Password Policy](https://supabase.com/docs/guides/auth/auth-password-policy)
- [OWASP Password Guidelines](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html#implement-proper-password-strength-controls)

---

## 📝 まとめ

✅ **実装済み**:
- クライアント側のパスワードバリデーション
- パスワードリセット機能
- セキュアなパスワード保存（Supabase Auth）

🔄 **推奨設定**:
- Supabaseダッシュボードで最低8文字に設定
- 大文字・小文字・数字を必須に設定
- パスワード強度インジケーターの実装（UX向上）

これらの対策により、Saikou! アプリのアカウントセキュリティが大幅に向上します！🎉
