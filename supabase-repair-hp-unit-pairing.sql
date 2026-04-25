-- Repair legacy HostPlatform unit rows so pairing uses the canonical model.
-- Safe to run multiple times in test, then live.

begin;

-- Manual/internal rows should not carry synthetic HP identities.
alter table public.units
  alter column hp_unit_id drop not null;

alter table public.units
  alter column hp_unit_id drop default;

-- Preserve existing synced rows, but normalize the legacy source name.
update public.units
set source = 'hostplatform'
where source = 'auto_synced';

-- Clear HP identity fields from internal rows after the legacy source migration.
update public.units
set
  hp_unit_id = null,
  hp_property_id = '',
  property_name = '',
  synced_at = null
where source <> 'hostplatform'
  and (
    hp_unit_id is not null
    or coalesce(hp_property_id, '') <> ''
    or coalesce(property_name, '') <> ''
    or synced_at is not null
  );

with legacy_matches as (
  select
    legacy.id as legacy_id,
    canonical.id as canonical_id,
    legacy.mapped_unit_name as legacy_mapped_unit_name,
    legacy.property_short as legacy_property_short
  from public.units as legacy
  join public.units as canonical
    on canonical.source = 'hostplatform'
   and canonical.active = true
   and coalesce(canonical.property_name, '') <> ''
   and lower(trim(regexp_replace(coalesce(canonical.property_name, '') || ' ' || coalesce(canonical.name, ''), '\s+', ' ', 'g')))
       = lower(trim(regexp_replace(coalesce(legacy.name, ''), '\s+', ' ', 'g')))
  where legacy.source = 'hostplatform'
    and legacy.active = true
    and coalesce(legacy.property_name, '') = ''
)
update public.units as canonical
set
  mapped_unit_name = case
    when coalesce(canonical.mapped_unit_name, '') = '' then coalesce(legacy_matches.legacy_mapped_unit_name, '')
    else canonical.mapped_unit_name
  end,
  property_short = case
    when coalesce(canonical.property_short, '') = '' then coalesce(legacy_matches.legacy_property_short, '')
    else canonical.property_short
  end
from legacy_matches
where canonical.id = legacy_matches.canonical_id;

with legacy_matches as (
  select legacy.id as legacy_id
  from public.units as legacy
  join public.units as canonical
    on canonical.source = 'hostplatform'
   and canonical.active = true
   and coalesce(canonical.property_name, '') <> ''
   and lower(trim(regexp_replace(coalesce(canonical.property_name, '') || ' ' || coalesce(canonical.name, ''), '\s+', ' ', 'g')))
       = lower(trim(regexp_replace(coalesce(legacy.name, ''), '\s+', ' ', 'g')))
  where legacy.source = 'hostplatform'
    and legacy.active = true
    and coalesce(legacy.property_name, '') = ''
)
update public.units
set active = false
where id in (select legacy_id from legacy_matches);

alter table public.units
  drop constraint if exists units_name_key;

create unique index if not exists units_internal_name_key
  on public.units (name)
  where source <> 'hostplatform';

drop index if exists public.units_hp_unit_id_idx;

create unique index if not exists units_hp_unit_id_idx
  on public.units (hp_unit_id);

commit;
