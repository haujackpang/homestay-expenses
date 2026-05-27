-- Data API grants audit.
-- Supabase CLI only returns the last result set for multi-statement files.
-- In the Dashboard SQL Editor, run both sections together.
-- In CLI, run this file to check function grants, and run
-- supabase-data-api-table-grants-audit.sql to check table grants.

select
  grantee,
  table_name,
  string_agg(privilege_type, ', ' order by privilege_type) as privileges
from information_schema.role_table_grants
where table_schema = 'public'
  and grantee in ('anon', 'authenticated', 'service_role')
  and table_name in (
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
  )
group by grantee, table_name
order by table_name, grantee;

select
  routine_name,
  grantee,
  privilege_type
from information_schema.routine_privileges
where routine_schema = 'public'
  and grantee in ('authenticated', 'service_role')
  and routine_name in ('get_my_role', 'get_my_name', 'find_possible_duplicate_claims')
order by routine_name, grantee;
