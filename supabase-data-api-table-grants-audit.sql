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
