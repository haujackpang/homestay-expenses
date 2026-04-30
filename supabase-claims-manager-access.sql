-- Focused claims visibility remediation for manager/admin workflows.
-- Run in test first. Promote to live only after explicit approval.
-- Safe to run multiple times.

begin;

alter table public.profiles
  drop constraint if exists profiles_role_check;

alter table public.profiles
  add constraint profiles_role_check
  check (role in ('employee', 'manager', 'admin'));

drop policy if exists "claims_select_admin" on public.claims;
drop policy if exists "Admin can read all claims" on public.claims;
drop policy if exists "claims_select_own" on public.claims;
drop policy if exists "Employee can read own claims" on public.claims;

create policy "claims_select_admin" on public.claims for select using (
  public.get_my_role() in ('admin', 'manager')
);

create policy "claims_select_own" on public.claims for select using (
  emp = public.get_my_name()
);

drop policy if exists "claims_update_admin" on public.claims;
drop policy if exists "Admin can update any claim" on public.claims;
drop policy if exists "claims_update_own" on public.claims;
drop policy if exists "Employee can update own claims" on public.claims;

create policy "claims_update_admin" on public.claims for update using (
  public.get_my_role() in ('admin', 'manager')
);

create policy "claims_update_own" on public.claims for update using (
  emp = public.get_my_name()
  and status in ('Draft', 'Submitted', 'Auto-Approved')
);

drop policy if exists "bank_info_insert" on public.bank_info;
drop policy if exists "Admin can insert bank_info" on public.bank_info;

create policy "bank_info_insert" on public.bank_info for insert with check (
  public.get_my_role() in ('admin', 'manager')
);

drop policy if exists "bank_info_update" on public.bank_info;
drop policy if exists "Admin can update bank_info" on public.bank_info;

create policy "bank_info_update" on public.bank_info for update using (
  public.get_my_role() in ('admin', 'manager')
);

commit;
