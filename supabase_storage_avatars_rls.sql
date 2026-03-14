-- Supabase Storage: avatars バケットの RLS ポリシー設定
-- これにより認証済みユーザーがアバター画像のアップロード・更新・削除が可能になり、
-- すべてのユーザー（未認証含む）が画像を閲覧できるようになります。

-- 1. アップロードポリシー（認証済みユーザーのみ）
CREATE POLICY IF NOT EXISTS "avatars_upload_policy"
ON storage.objects 
FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'avatars');

-- 2. 公開読み取りポリシー（すべてのユーザー）
CREATE POLICY IF NOT EXISTS "avatars_public_read_policy"
ON storage.objects 
FOR SELECT 
TO public 
USING (bucket_id = 'avatars');

-- 3. 更新ポリシー（認証済みユーザーのみ）
CREATE POLICY IF NOT EXISTS "avatars_update_policy"
ON storage.objects 
FOR UPDATE 
TO authenticated 
USING (bucket_id = 'avatars') 
WITH CHECK (bucket_id = 'avatars');

-- 4. 削除ポリシー（認証済みユーザーのみ）
CREATE POLICY IF NOT EXISTS "avatars_delete_policy"
ON storage.objects 
FOR DELETE 
TO authenticated 
USING (bucket_id = 'avatars');
