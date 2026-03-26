-- =======================================
-- Admin Account & User Management Setup
-- Run this in Supabase SQL Editor (one-time)
-- =======================================

-- 1. Enable pgcrypto if not already enabled
CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA extensions;

-- 2. Update profiles role constraint to include 'manager'
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('employee', 'manager', 'admin'));

-- 3. Update RLS policies to support manager role for claims
DROP POLICY IF EXISTS "claims_select_admin" ON claims;
CREATE POLICY "claims_select_admin" ON claims FOR SELECT USING (
  public.get_my_role() IN ('admin', 'manager')
);

DROP POLICY IF EXISTS "claims_insert" ON claims;
CREATE POLICY "claims_insert" ON claims FOR INSERT WITH CHECK (
  auth.uid() IS NOT NULL
);

DROP POLICY IF EXISTS "claims_update_admin" ON claims;
CREATE POLICY "claims_update_admin" ON claims FOR UPDATE USING (
  public.get_my_role() IN ('admin', 'manager')
);

-- Update bank_info policies for manager role
DROP POLICY IF EXISTS "bank_info_update" ON bank_info;
CREATE POLICY "bank_info_update" ON bank_info FOR UPDATE USING (
  public.get_my_role() IN ('admin', 'manager')
);

DROP POLICY IF EXISTS "bank_info_insert" ON bank_info;
CREATE POLICY "bank_info_insert" ON bank_info FOR INSERT WITH CHECK (
  public.get_my_role() IN ('admin', 'manager')
);

-- 4. Function: Admin creates a user account
CREATE OR REPLACE FUNCTION admin_create_user(
  p_username text,
  p_password text,
  p_full_name text,
  p_role text DEFAULT 'employee'
) RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  new_id uuid := gen_random_uuid();
  p_email text := lower(p_username) || '@homestay.app';
BEGIN
  -- Only admin can call this
  IF public.get_my_role() != 'admin' THEN
    RAISE EXCEPTION 'Only admin can create users';
  END IF;

  -- Validate role
  IF p_role NOT IN ('employee', 'manager') THEN
    RAISE EXCEPTION 'Role must be employee or manager';
  END IF;

  -- Validate password length
  IF length(p_password) < 6 THEN
    RAISE EXCEPTION 'Password must be at least 6 characters';
  END IF;

  -- Check if username already exists
  IF EXISTS (SELECT 1 FROM auth.users WHERE email = p_email) THEN
    RAISE EXCEPTION 'Username already exists';
  END IF;

  -- Check if full_name already exists in profiles
  IF EXISTS (SELECT 1 FROM profiles WHERE full_name = p_full_name) THEN
    RAISE EXCEPTION 'A user with this name already exists';
  END IF;

  -- Create auth user
  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at, confirmation_token,
    email_change_token_new, recovery_token
  ) VALUES (
    new_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    p_email,
    crypt(p_password, gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('full_name', p_full_name),
    now(), now(), '', '', ''
  );

  -- Create identity record (required for Supabase Auth login)
  INSERT INTO auth.identities (
    id, user_id, identity_data, provider, provider_id,
    last_sign_in_at, created_at, updated_at
  ) VALUES (
    gen_random_uuid(),
    new_id,
    jsonb_build_object('sub', new_id::text, 'email', p_email, 'email_verified', true),
    'email',
    new_id::text,
    now(), now(), now()
  );

  -- Create profile
  INSERT INTO profiles (id, email, full_name, role)
  VALUES (new_id, p_email, p_full_name, p_role);

  -- Create bank_info entry for employees
  IF p_role = 'employee' THEN
    INSERT INTO bank_info (employee_name)
    VALUES (p_full_name)
    ON CONFLICT (employee_name) DO NOTHING;
  END IF;

  RETURN new_id;
END;
$$;

-- 5. Function: Admin updates a user account
CREATE OR REPLACE FUNCTION admin_update_user(
  p_user_id uuid,
  p_full_name text DEFAULT NULL,
  p_role text DEFAULT NULL,
  p_password text DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  old_name text;
  old_role text;
BEGIN
  IF public.get_my_role() != 'admin' THEN
    RAISE EXCEPTION 'Only admin can update users';
  END IF;

  -- Cannot modify admin account
  SELECT role, full_name INTO old_role, old_name FROM profiles WHERE id = p_user_id;
  IF old_role IS NULL THEN
    RAISE EXCEPTION 'User not found';
  END IF;
  IF old_role = 'admin' THEN
    RAISE EXCEPTION 'Cannot modify admin account';
  END IF;

  -- Validate new role
  IF p_role IS NOT NULL AND p_role NOT IN ('employee', 'manager') THEN
    RAISE EXCEPTION 'Role must be employee or manager';
  END IF;

  -- Validate password length
  IF p_password IS NOT NULL AND length(p_password) < 6 THEN
    RAISE EXCEPTION 'Password must be at least 6 characters';
  END IF;

  -- Update profile
  UPDATE profiles SET
    full_name = COALESCE(p_full_name, full_name),
    role = COALESCE(p_role, role)
  WHERE id = p_user_id;

  -- Update bank_info employee_name if name changed
  IF p_full_name IS NOT NULL AND p_full_name != old_name THEN
    UPDATE bank_info SET employee_name = p_full_name
    WHERE employee_name = old_name;
  END IF;

  -- Update password if provided
  IF p_password IS NOT NULL THEN
    UPDATE auth.users SET
      encrypted_password = crypt(p_password, gen_salt('bf')),
      updated_at = now()
    WHERE id = p_user_id;
  END IF;
END;
$$;

-- 6. Function: Admin deletes a user account
CREATE OR REPLACE FUNCTION admin_delete_user(p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  target_role text;
BEGIN
  IF public.get_my_role() != 'admin' THEN
    RAISE EXCEPTION 'Only admin can delete users';
  END IF;

  -- Cannot delete self
  IF p_user_id = auth.uid() THEN
    RAISE EXCEPTION 'Cannot delete your own account';
  END IF;

  -- Cannot delete admin
  SELECT role INTO target_role FROM profiles WHERE id = p_user_id;
  IF target_role IS NULL THEN
    RAISE EXCEPTION 'User not found';
  END IF;
  IF target_role = 'admin' THEN
    RAISE EXCEPTION 'Cannot delete admin account';
  END IF;

  -- Delete in correct order (FK constraints)
  DELETE FROM profiles WHERE id = p_user_id;
  DELETE FROM auth.identities WHERE user_id = p_user_id;
  DELETE FROM auth.users WHERE id = p_user_id;
  -- Note: bank_info and claims use employee name, not user_id FK
END;
$$;

-- 7. Function: List all users (admin only)
CREATE OR REPLACE FUNCTION list_users()
RETURNS TABLE(id uuid, email text, full_name text, role text, created_at timestamptz)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF public.get_my_role() != 'admin' THEN
    RAISE EXCEPTION 'Only admin can list users';
  END IF;

  RETURN QUERY
  SELECT p.id, p.email, p.full_name, p.role, p.created_at
  FROM profiles p
  ORDER BY
    CASE p.role WHEN 'admin' THEN 0 WHEN 'manager' THEN 1 ELSE 2 END,
    p.created_at;
END;
$$;

-- 8. Pre-create admin account (admin / MP@2018)
DO $$
DECLARE
  admin_id uuid := gen_random_uuid();
BEGIN
  -- Only create if admin doesn't exist yet
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'admin@homestay.app') THEN
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password,
      email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
      created_at, updated_at, confirmation_token,
      email_change_token_new, recovery_token
    ) VALUES (
      admin_id,
      '00000000-0000-0000-0000-000000000000',
      'authenticated',
      'authenticated',
      'admin@homestay.app',
      extensions.crypt('MP@2018', extensions.gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"full_name":"System Admin"}'::jsonb,
      now(), now(), '', '', ''
    );

    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, provider_id,
      last_sign_in_at, created_at, updated_at
    ) VALUES (
      gen_random_uuid(),
      admin_id,
      jsonb_build_object('sub', admin_id::text, 'email', 'admin@homestay.app', 'email_verified', true),
      'email',
      admin_id::text,
      now(), now(), now()
    );

    INSERT INTO profiles (id, email, full_name, role)
    VALUES (admin_id, 'admin@homestay.app', 'System Admin', 'admin');

    RAISE NOTICE 'Admin account created successfully: username=admin, password=MP@2018';
  ELSE
    RAISE NOTICE 'Admin account already exists â€” skipped.';
  END IF;
END $$;
