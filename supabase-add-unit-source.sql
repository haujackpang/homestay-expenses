-- ============================================================
-- Add source & last_reservation_at columns to units table
-- Run in Supabase SQL Editor (Dashboard > SQL Editor)
-- ============================================================

-- Add source column: 'manual' or 'auto_synced'
ALTER TABLE units ADD COLUMN IF NOT EXISTS
  source TEXT NOT NULL DEFAULT 'manual';

-- Add last_reservation_at: for tracking when unit was last seen in a reservation
ALTER TABLE units ADD COLUMN IF NOT EXISTS
  last_reservation_at TIMESTAMPTZ;

-- Existing units keep source = 'manual' (default)
-- Auto-synced ones will be updated when next sync runs

-- ============================================================
-- DONE! Ready for auto-sync from reservations.
-- ============================================================
