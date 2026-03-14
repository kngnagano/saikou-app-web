-- Supabase Storage: avatars バケットの RLS ポリシー設定
-- 既存のポリシーがある場合はエラーになりますが、それは正常です

-- 既存のポリシーを削除（エラーが出ても問題ありません）
DROP POLICY IF EXISTS "avatars_upload_policy" ON storage.objects;
DROP POLICY IF EXISTS "avatars_public_read_policy" ON storage.objects;
DROP POLICY IF EXISTS "avatars_update_policy" ON storage.objects;
DROP POLICY IF EXISTS "avatars_delete_policy" ON storage.objects;

-- 1. アップロードポリシー（認証済みユーザーのみ）
CREATE POLICY "avatars_upload_policy"
ON storage.objects 
FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'avatars');

-- 2. 公開読み取りポリシー（すべてのユーザー）
CREATE POLICY "avatars_public_read_policy"
ON storage.objects 
FOR SELECT 
TO public 
USING (bucket_id = 'avatars');

-- 3. 更新ポリシー（認証済みユーザーのみ）
CREATE POLICY "avatars_update_policy"
ON storage.objects 
FOR UPDATE 
TO authenticated 
USING (bucket_id = 'avatars') 
WITH CHECK (bucket_id = 'avatars');

-- 4. 削除ポリシー（認証済みユーザーのみ）
CREATE POLICY "avatars_delete_policy"
ON storage.objects 
FOR DELETE 
TO authenticated 
USING (bucket_id = 'avatars');
