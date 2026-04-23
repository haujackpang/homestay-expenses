-- Add explicit HostPlatform unit -> internal unit mapping.
-- Safe to run multiple times.

ALTER TABLE public.units
  ADD COLUMN IF NOT EXISTS mapped_unit_name text NOT NULL DEFAULT '';

CREATE INDEX IF NOT EXISTS idx_units_mapped_unit_name
  ON public.units (mapped_unit_name);

