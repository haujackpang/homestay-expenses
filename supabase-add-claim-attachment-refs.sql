-- ============================================================
-- Claims attachment fields split
-- - Adds dedicated receipt and payment slip columns
-- - Backfills legacy slip_ref safely
-- ============================================================

alter table if exists public.claims
  add column if not exists receipt_refs text default '';

alter table if exists public.claims
  add column if not exists payment_slip_refs text default '';

update public.claims
set receipt_refs = coalesce(nullif(slip_ref, ''), '')
where coalesce(receipt_refs, '') = ''
  and coalesce(payment_slip_refs, '') = ''
  and coalesce(slip_ref, '') <> ''
  and status <> 'Claimed';

update public.claims
set payment_slip_refs = coalesce(nullif(slip_ref, ''), '')
where coalesce(payment_slip_refs, '') = ''
  and coalesce(receipt_refs, '') = ''
  and coalesce(slip_ref, '') <> ''
  and status = 'Claimed';
