-- Test-only claim delete policy repair.
-- Paste into Supabase SQL Editor while linked to the TEST project.
-- This replaces legacy delete policies with the current unpaid-claim rules.

-- 1. Inspect current delete policies before changing anything.
select policyname, cmd, qual
from pg_policies
where schemaname = 'public'
  and tablename = 'claims'
  and cmd = 'DELETE';

begin;

drop policy if exists "Admin can delete any claim" on public.claims;
drop policy if exists "Employee can delete own claims" on public.claims;
drop policy if exists "claims_delete_employee_unpaid" on public.claims;
drop policy if exists "claims_delete_manager_unpaid" on public.claims;

create policy "claims_delete_employee_unpaid" on public.claims
  for delete using (
    emp = public.get_my_name()
    and coalesce(status, '') not in ('Claimed', 'Company-Paid')
  );

create policy "claims_delete_manager_unpaid" on public.claims
  for delete using (
    public.get_my_role() in ('admin', 'manager')
    and coalesce(status, '') not in ('Claimed', 'Company-Paid')
  );

commit;

-- 2. Verify the active delete policies after the repair.
select policyname, cmd, qual
from pg_policies
where schemaname = 'public'
  and tablename = 'claims'
  and cmd = 'DELETE'
order by policyname;

-- 3. Optional: confirm the target claim is still unpaid and therefore deletable.
select claim_id, status, emp, pay_type, submitted_by
from public.claims
where claim_id = 'MGR-2026-05-00121';
