-- ============================================================
-- Data API explicit grants for Supabase public-schema access
-- ============================================================
-- Supabase is removing automatic Data API exposure for new public tables.
-- Keep this script aligned with any table/function that the browser app,
-- Edge Functions using supabase-js, or REST/RPC access must reach.
--
-- Run in test first. Promote to live only after explicit approval.
-- Safe to run multiple times.

begin;

grant usage on schema public to anon, authenticated, service_role;

-- Logged-in browser app access. RLS policies still decide row-level access.
do $$
declare
  table_name text;
  table_names text[] := array[
    'profiles',
    'bank_info',
    'claims',
    'claim_sequences',
    'claim_counter',
    'units',
    'unit_unavailability',
    'unit_types',
    'unit_config',
    'reservations',
    'sync_logs',
    'error_logs',
    'gl_codes',
    'owner_unit_access'
  ];
begin
  foreach table_name in array table_names loop
    if to_regclass(format('public.%I', table_name)) is not null then
      execute format('revoke all privileges on table public.%I from anon', table_name);
      execute format('revoke all privileges on table public.%I from authenticated', table_name);
      execute format('revoke all privileges on table public.%I from service_role', table_name);
      execute format('grant select, insert, update, delete on table public.%I to authenticated', table_name);
      execute format('grant select, insert, update, delete on table public.%I to service_role', table_name);
    end if;
  end loop;
end $$;

-- Browser diagnostics before login. Keep this narrow.
grant insert on table public.error_logs to anon;

-- Identity columns/sequences used by public tables, if present.
grant usage, select on all sequences in schema public to authenticated, service_role;
grant usage, select on all sequences in schema public to anon;

-- RPC/function access used by RLS helpers and invoice duplicate detection.
do $$
begin
  if to_regprocedure('public.get_my_role()') is not null then
    grant execute on function public.get_my_role() to authenticated, service_role;
  end if;

  if to_regprocedure('public.get_my_name()') is not null then
    grant execute on function public.get_my_name() to authenticated, service_role;
  end if;

  if to_regprocedure('public.find_possible_duplicate_claims(text,text,numeric,text,text,text)') is not null then
    grant execute on function public.find_possible_duplicate_claims(text,text,numeric,text,text,text) to authenticated, service_role;
  end if;
end $$;

commit;
