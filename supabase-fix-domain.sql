-- =======================================
-- Fix: Change email domain to @homestay.app
-- Run this in Supabase SQL Editor
-- =======================================

-- 1. Delete the broken admin@homestay.local user
DELETE FROM profiles WHERE email = 'admin@homestay.local';
DELETE FROM auth.identities WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'admin@homestay.local');
DELETE FROM auth.users WHERE email = 'admin@homestay.local';

-- 2. Delete the test user created during debugging
DELETE FROM auth.identities WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'testuser@homestay.app');
DELETE FROM auth.users WHERE email = 'testuser@homestay.app';

-- 3. Recreate admin with @homestay.app domain
DO $$
DECLARE
  admin_id uuid := gen_random_uuid();
BEGIN
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

    RAISE NOTICE 'Admin account recreated with @homestay.app';
  END IF;
END $$;

-- 4. Update the admin_create_user function to use @homestay.app
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
  IF public.get_my_role() != 'admin' THEN
    RAISE EXCEPTION 'Only admin can create users';
  END IF;
  IF p_role NOT IN ('employee', 'manager') THEN
    RAISE EXCEPTION 'Role must be employee or manager';
  END IF;
  IF length(p_password) < 6 THEN
    RAISE EXCEPTION 'Password must be at least 6 characters';
  END IF;
  IF EXISTS (SELECT 1 FROM auth.users WHERE email = p_email) THEN
    RAISE EXCEPTION 'Username already exists';
  END IF;
  IF EXISTS (SELECT 1 FROM profiles WHERE full_name = p_full_name) THEN
    RAISE EXCEPTION 'A user with this name already exists';
  END IF;

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

  INSERT INTO profiles (id, email, full_name, role)
  VALUES (new_id, p_email, p_full_name, p_role);

  IF p_role = 'employee' THEN
    INSERT INTO bank_info (employee_name)
    VALUES (p_full_name)
    ON CONFLICT (employee_name) DO NOTHING;
  END IF;

  RETURN new_id;
END;
$$;

-- 5. Verify
SELECT id, email, full_name, role FROM profiles ORDER BY created_at;
