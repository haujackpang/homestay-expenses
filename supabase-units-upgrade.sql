-- ============================================================
-- HP Units Sync Schema Upgrade
-- Run in Supabase SQL Editor (project: skwogboredsczcyhlqgn)
-- ============================================================

-- 1. Add new columns to units table
ALTER TABLE units ADD COLUMN IF NOT EXISTS
  hp_unit_id TEXT NOT NULL DEFAULT gen_random_uuid()::text;

ALTER TABLE units ADD COLUMN IF NOT EXISTS
  property_name TEXT NOT NULL DEFAULT '';

ALTER TABLE units ADD COLUMN IF NOT EXISTS
  property_short TEXT NOT NULL DEFAULT '';

ALTER TABLE units ADD COLUMN IF NOT EXISTS
  hp_property_id TEXT NOT NULL DEFAULT '';

ALTER TABLE units ADD COLUMN IF NOT EXISTS
  synced_at TIMESTAMPTZ;

-- 2. Create unique index on hp_unit_id (NULLs not applicable since we default to UUID)
CREATE UNIQUE INDEX IF NOT EXISTS units_hp_unit_id_idx ON units (hp_unit_id);

-- 3. Add hp_unit_id to claims table (references the unit's hp_unit_id)
ALTER TABLE claims ADD COLUMN IF NOT EXISTS
  hp_unit_id TEXT;

-- 4. Add hp_unit_id to reservations table (for linking reservations to units)
ALTER TABLE reservations ADD COLUMN IF NOT EXISTS
  hp_unit_id TEXT;

-- 4. Ensure MP Office exists and is source='manual'
INSERT INTO units (name, source, active)
  VALUES ('MP Office', 'manual', true)
  ON CONFLICT (name) DO UPDATE SET source = 'manual';

-- 5. Delete all non-manual units (sync-units Edge Function will repopulate from HP)
--    Manual units (MP Office etc.) are kept.
DELETE FROM units WHERE source != 'manual';

-- ============================================================
-- After running this SQL:
--   1. Deploy sync-units Edge Function
--   2. Trigger sync from Admin > Units > "Sync from HP" button
--   3. Set property_short for each property in Admin > Units
--   4. Use Re-match Claims screen to link historical claims to HP units
-- ============================================================
