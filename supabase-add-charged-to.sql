-- ============================================================
-- Migration: Add charged_to column to claims table
-- Run this in Supabase Dashboard > SQL Editor
-- ============================================================

-- 1. Add charged_to column (who bears this expense cost)
ALTER TABLE claims ADD COLUMN IF NOT EXISTS charged_to TEXT DEFAULT '';

-- 2. Backfill existing rows to empty string
UPDATE claims SET charged_to = '' WHERE charged_to IS NULL;

-- 3. Add check constraint
ALTER TABLE claims DROP CONSTRAINT IF EXISTS claims_charged_to_check;
ALTER TABLE claims ADD CONSTRAINT claims_charged_to_check
  CHECK (charged_to IN ('', 'Owner', 'Operator', 'Both'));
