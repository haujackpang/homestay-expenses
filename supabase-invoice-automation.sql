-- ============================================================
-- Invoice automation upgrade
-- Run this in Supabase Dashboard > SQL Editor for each environment.
-- ============================================================

alter table public.claims add column if not exists invoice_number text default '';
alter table public.claims add column if not exists merchant_name text default '';
alter table public.claims add column if not exists ai_raw jsonb default '{}'::jsonb;
alter table public.claims add column if not exists ai_confidence numeric default 0;
alter table public.claims add column if not exists source_type text default 'manual';
alter table public.claims add column if not exists external_id text;
alter table public.claims add column if not exists external_source text;

create unique index if not exists claims_external_source_id_idx
on public.claims (external_source, external_id)
where external_id is not null and external_source is not null;

create index if not exists claims_invoice_lookup_idx
on public.claims (invoice_number, merchant_name, amount, expense_month)
where invoice_number is not null and invoice_number <> '';

create or replace function public.find_possible_duplicate_claims(
  p_invoice_number text,
  p_merchant_name text,
  p_amount numeric,
  p_expense_month text,
  p_emp text default null,
  p_unit text default null
)
returns table (
  claim_id text,
  emp text,
  unit text,
  description text,
  amount numeric,
  date date,
  status text,
  duplicate_reason text
)
language sql
stable
security definer
set search_path = public
as $$
  select
    c.claim_id,
    c.emp,
    c.unit,
    c.description,
    c.amount,
    c.date,
    c.status,
    case
      when coalesce(p_invoice_number, '') <> ''
        and lower(coalesce(c.invoice_number, '')) = lower(p_invoice_number)
        then 'invoice_number'
      when coalesce(p_merchant_name, '') <> ''
        and lower(coalesce(c.merchant_name, '')) = lower(p_merchant_name)
        and c.amount = p_amount
        and coalesce(c.expense_month, to_char(c.date, 'YYYY-MM')) = p_expense_month
        then 'merchant_amount_month'
      else 'amount_month_party'
    end as duplicate_reason
  from public.claims c
  where c.status not in ('Rejected', 'Draft')
    and (
      (
        coalesce(p_invoice_number, '') <> ''
        and lower(coalesce(c.invoice_number, '')) = lower(p_invoice_number)
      )
      or (
        coalesce(p_merchant_name, '') <> ''
        and lower(coalesce(c.merchant_name, '')) = lower(p_merchant_name)
        and c.amount = p_amount
        and coalesce(c.expense_month, to_char(c.date, 'YYYY-MM')) = p_expense_month
      )
      or (
        c.amount = p_amount
        and coalesce(c.expense_month, to_char(c.date, 'YYYY-MM')) = p_expense_month
        and (
          (coalesce(p_emp, '') <> '' and c.emp = p_emp)
          or (coalesce(p_unit, '') <> '' and c.unit = p_unit)
        )
      )
    )
  order by c.created_at desc
  limit 10;
$$;
