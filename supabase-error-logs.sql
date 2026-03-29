-- ============================================================
-- Error Tracking Log Table
-- Run this in Supabase SQL Editor (Dashboard > SQL Editor)
-- ============================================================

-- Create error_logs table
CREATE TABLE IF NOT EXISTS error_logs (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at  TIMESTAMPTZ DEFAULT now() NOT NULL,
  level       TEXT NOT NULL DEFAULT 'error',          -- 'info', 'warn', 'error', 'fatal'
  source      TEXT NOT NULL DEFAULT 'unknown',         -- e.g. 'analyze-receipt', 'frontend', 'auth'
  message     TEXT NOT NULL,
  details     JSONB DEFAULT '{}'::jsonb,               -- extra context: model, status, stack, etc.
  user_agent  TEXT,                                     -- browser/device info (optional)
  resolved    BOOLEAN DEFAULT false                    -- mark resolved after debugging
);

-- Index for fast querying
CREATE INDEX IF NOT EXISTS idx_error_logs_created_at ON error_logs (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_error_logs_level ON error_logs (level);
CREATE INDEX IF NOT EXISTS idx_error_logs_source ON error_logs (source);

-- Enable RLS
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;

-- Service role (Edge Functions) can INSERT
CREATE POLICY "Service role can insert error logs"
  ON error_logs FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Service role can SELECT (for admin viewing)
CREATE POLICY "Service role can read error logs"
  ON error_logs FOR SELECT
  TO service_role
  USING (true);

-- Anon users can INSERT (frontend error logging) 
CREATE POLICY "Anon can insert error logs"
  ON error_logs FOR INSERT
  TO anon
  WITH CHECK (true);

-- Anon users can SELECT (for admin log viewer in app)
CREATE POLICY "Anon can read error logs"
  ON error_logs FOR SELECT
  TO anon
  USING (true);

-- Service role can UPDATE (mark resolved)
CREATE POLICY "Service role can update error logs"
  ON error_logs FOR UPDATE
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Anon can UPDATE (mark resolved from app)
CREATE POLICY "Anon can update error logs"
  ON error_logs FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

-- Auto-cleanup: delete logs older than 90 days (optional, run manually or via cron)
-- DELETE FROM error_logs WHERE created_at < now() - INTERVAL '90 days';

-- ============================================================
-- DONE! Table is ready for error tracking.
-- ============================================================
