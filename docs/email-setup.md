# Supabase 登録完了メール設定ガイド

## 概要
このガイドでは、Saikou! アプリの新規登録時に自動送信される「登録完了メール」を設定する方法を説明します。

## 前提条件
- Supabaseプロジェクトの管理者権限
- プロジェクトID: `mthfqqqukuvueprdokiq`

## 設定手順

### 1. Supabaseダッシュボードにアクセス

https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/auth/templates

### 2. Email Templatesページを開く

左メニュー: **Authentication** → **Email Templates**

### 3. Confirm signup テンプレートの編集

デフォルトでは「Confirm signup」テンプレートが新規登録時に送信されます。

#### 推奨設定:

**Subject（件名）**:
```
Saikou! へようこそ 🎉 登録が完了しました
```

**Body（本文）**:
```html
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Saikou! 登録完了</title>
</head>
<body style="font-family: 'Helvetica Neue', Arial, 'Noto Sans JP', sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  
  <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
    <h1 style="color: white; margin: 0; font-size: 28px;">🎉 ようこそ Saikou! へ</h1>
  </div>
  
  <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
    <p style="font-size: 16px; margin-bottom: 20px;">
      こんにちは！<br>
      Saikou! への登録が完了しました。
    </p>
    
    <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #667eea;">
      <h2 style="margin-top: 0; color: #667eea; font-size: 18px;">📧 登録情報</h2>
      <p style="margin: 10px 0;">
        <strong>メールアドレス:</strong> {{ .Email }}<br>
        <strong>表示名:</strong> {{ .Metadata.display_name }}
      </p>
    </div>
    
    <h3 style="color: #667eea; font-size: 18px;">✨ Saikou! でできること</h3>
    <ul style="list-style: none; padding: 0;">
      <li style="padding: 10px 0; border-bottom: 1px solid #eee;">
        📝 毎日の習慣を3つまでトラッキング
      </li>
      <li style="padding: 10px 0; border-bottom: 1px solid #eee;">
        🔥 継続日数（ストリーク）を記録
      </li>
      <li style="padding: 10px 0; border-bottom: 1px solid #eee;">
        👥 友達と一緒に目標達成を目指す
      </li>
      <li style="padding: 10px 0; border-bottom: 1px solid #eee;">
        ✅ 日々の達成を「コミット」して記録
      </li>
    </ul>
    
    <div style="margin: 30px 0; text-align: center;">
      <a href="{{ .SiteURL }}" style="display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 15px 40px; text-decoration: none; border-radius: 25px; font-weight: bold; font-size: 16px;">
        今すぐ始める 🚀
      </a>
    </div>
    
    <div style="background: #fff3cd; padding: 15px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #ffc107;">
      <p style="margin: 0; font-size: 14px; color: #856404;">
        💡 <strong>ヒント:</strong> 友達を招待してSaikou! を一緒に使うと、モチベーションがさらにアップします！
      </p>
    </div>
    
    <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
    
    <p style="font-size: 14px; color: #666; text-align: center; margin: 20px 0;">
      ご不明な点がございましたら、<br>
      アプリ内のお問い合わせフォームからご連絡ください。
    </p>
    
    <p style="font-size: 12px; color: #999; text-align: center; margin: 20px 0;">
      <a href="{{ .SiteURL }}/terms.html" style="color: #667eea; text-decoration: none;">利用規約</a> |
      <a href="{{ .SiteURL }}/privacy.html" style="color: #667eea; text-decoration: none;">プライバシーポリシー</a>
    </p>
    
    <p style="font-size: 12px; color: #999; text-align: center;">
      © 2026 Saikou Team. All rights reserved.
    </p>
  </div>
  
</body>
</html>
```

### 4. 変数の説明

Supabaseが自動で置換する変数:

| 変数 | 説明 | 例 |
|------|------|------|
| `{{ .Email }}` | ユーザーのメールアドレス | `user@example.com` |
| `{{ .SiteURL }}` | アプリのURL | `https://gegsmoop.gensparkspace.com/` |
| `{{ .Metadata.display_name }}` | ユーザーの表示名（カスタムメタデータ） | `山田太郎` |

### 5. テスト送信

1. **Save** ボタンをクリックして保存
2. 新規ユーザーを登録してメールが届くか確認
3. 件名、本文、リンクが正しく表示されるか確認

## トラブルシューティング

### メールが届かない場合

1. **Spam/迷惑メールフォルダを確認**
2. **Supabase Email設定を確認**:
   - Authentication → Settings → Email Auth
   - "Confirm email" が OFF になっているか確認
3. **Email送信レート制限を確認**:
   - Authentication → Settings → Rate Limits
   - "Email rate limit" が適切に設定されているか確認（推奨: 100 emails/hour）

### 変数が表示されない場合

- `{{ .Metadata.display_name }}` が表示されない場合:
  - 新規登録時に `user_metadata` に `display_name` が正しく設定されているか確認
  - handleSetup関数で以下のように設定:
    ```javascript
    const { data: authData, error: signupError } = await supabase.auth.signUp({
      email: email,
      password: password,
      options: {
        data: {
          display_name: displayName  // ← これが重要
        }
      }
    });
    ```

## 補足：Custom SMTP設定（オプショナル）

より高度な設定やカスタムドメインからのメール送信を行いたい場合は、Custom SMTPを設定できます。

https://supabase.com/dashboard/project/mthfqqqukuvueprdokiq/settings/auth

1. **Settings** → **Auth** → **SMTP Settings**
2. SMTPサーバー情報を入力（Gmail、SendGrid、AWS SES等）
3. 送信元アドレスを設定（例: `noreply@saikou-app.com`）

## 注意事項

- ⚠️ **本番環境では必ずメール確認を有効化**してください（現在は開発のため無効化中）
- 📧 **送信レート制限**に注意してください（無料プランの制限あり）
- 🔒 **個人情報**がメールに含まれる場合は、プライバシーポリシーに記載してください

## 関連ドキュメント

- [Supabase Auth Email Templates](https://supabase.com/docs/guides/auth/auth-email-templates)
- [Supabase Auth Configuration](https://supabase.com/docs/guides/auth/auth-smtp)
