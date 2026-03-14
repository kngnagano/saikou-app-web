DROP POLICY IF EXISTS "avatars_upload_policy" ON storage.objects;
DROP POLICY IF EXISTS "avatars_public_read_policy" ON storage.objects;
DROP POLICY IF EXISTS "avatars_update_policy" ON storage.objects;
DROP POLICY IF EXISTS "avatars_delete_policy" ON storage.objects;

CREATE POLICY "avatars_upload_policy"
ON storage.objects 
FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "avatars_public_read_policy"
ON storage.objects 
FOR SELECT 
TO public 
USING (bucket_id = 'avatars');

CREATE POLICY "avatars_update_policy"
ON storage.objects 
FOR UPDATE 
TO authenticated 
USING (bucket_id = 'avatars') 
WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "avatars_delete_policy"
ON storage.objects 
FOR DELETE 
TO authenticated 
USING (bucket_id = 'avatars');
