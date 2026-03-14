-- ===================================
-- Supabase Storage: Avatars Bucket Setup
-- ===================================
-- Purpose: Ensure the 'avatars' bucket exists with proper permissions
-- Run this in Supabase SQL Editor if avatar upload fails

-- ===================================
-- Step 1: Check if avatars bucket exists
-- ===================================

-- Query storage.buckets to see if 'avatars' exists
SELECT 
  id, 
  name, 
  public,
  file_size_limit,
  allowed_mime_types
FROM storage.buckets 
WHERE name = 'avatars';

-- If the query returns no results, the bucket doesn't exist
-- In that case, create it via Supabase Dashboard:
-- 1. Go to Storage in Supabase Dashboard
-- 2. Click "New Bucket"
-- 3. Name: avatars
-- 4. Public: Yes (checked)
-- 5. File size limit: 5242880 (5MB)
-- 6. Allowed MIME types: image/jpeg, image/jpg, image/png, image/webp, image/heic, image/heif
-- 7. Click "Create Bucket"

-- ===================================
-- Step 2: Check Storage Policies
-- ===================================

-- List all policies for the avatars bucket
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE '%avatars%';

-- ===================================
-- Step 3: Create RLS Policies (if needed)
-- ===================================

-- Enable RLS on storage.objects (usually already enabled)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Policy 1: Allow authenticated users to upload to avatars/
CREATE POLICY IF NOT EXISTS "avatars_upload_policy"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy 2: Allow public read access to avatars
CREATE POLICY IF NOT EXISTS "avatars_public_read_policy"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Policy 3: Allow users to update their own avatars
CREATE POLICY IF NOT EXISTS "avatars_update_policy"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy 4: Allow users to delete their own avatars
CREATE POLICY IF NOT EXISTS "avatars_delete_policy"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ===================================
-- Step 4: Verify Policies
-- ===================================

SELECT 
  policyname,
  CASE cmd
    WHEN 'r' THEN 'SELECT'
    WHEN 'a' THEN 'INSERT'
    WHEN 'w' THEN 'UPDATE'
    WHEN 'd' THEN 'DELETE'
    WHEN '*' THEN 'ALL'
  END as operation,
  roles
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE '%avatars%'
ORDER BY policyname;

-- ===================================
-- Step 5: Test Upload (via JavaScript)
-- ===================================

/*
After running the above SQL, test the upload in your app:

1. Open browser console (F12)
2. Try uploading an image
3. Check console logs for detailed error messages
4. If you see "bucket not found" error:
   - Create bucket via Dashboard (see Step 1)
5. If you see "permission denied" error:
   - Rerun Step 3 policies
6. If you see "invalid file type" error:
   - Check allowed MIME types in bucket settings
*/

-- ===================================
-- Troubleshooting Commands
-- ===================================

-- Check if user is authenticated
SELECT auth.uid();
-- Should return a UUID, not NULL

-- List all buckets
SELECT * FROM storage.buckets;

-- List all files in avatars bucket (if it exists)
SELECT name, created_at, updated_at 
FROM storage.objects 
WHERE bucket_id = 'avatars' 
ORDER BY created_at DESC 
LIMIT 10;

-- Check bucket size
SELECT 
  bucket_id,
  COUNT(*) as file_count,
  SUM(metadata->>'size')::bigint as total_size_bytes,
  ROUND(SUM((metadata->>'size')::bigint) / 1024.0 / 1024.0, 2) as total_size_mb
FROM storage.objects
WHERE bucket_id = 'avatars'
GROUP BY bucket_id;

-- ===================================
-- DONE!
-- ===================================
