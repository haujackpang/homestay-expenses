-- Add unit-level cleaning/laundry rates into unit_config
-- Safe to run multiple times.

ALTER TABLE public.unit_config
  ADD COLUMN IF NOT EXISTS cleaning_fee numeric NOT NULL DEFAULT 0;

ALTER TABLE public.unit_config
  ADD COLUMN IF NOT EXISTS laundry_fee numeric NOT NULL DEFAULT 0;

-- Optional backfill from legacy unit_types mapping.
-- Keeps any unit-level values already set.
UPDATE public.unit_config uc
SET
  cleaning_fee = CASE WHEN uc.cleaning_fee = 0 THEN COALESCE(ut.cleaning_fee,0) ELSE uc.cleaning_fee END,
  laundry_fee = CASE WHEN uc.laundry_fee = 0 THEN COALESCE(ut.laundry_fee,0) ELSE uc.laundry_fee END
FROM public.unit_types ut
WHERE uc.unit_type = ut.name;

