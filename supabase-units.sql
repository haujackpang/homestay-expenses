-- ===== UNITS TABLE =====
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS units (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL UNIQUE,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE units ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read units
CREATE POLICY "Authenticated users can read units"
  ON units FOR SELECT TO authenticated USING (true);

-- Managers and admins can insert units
CREATE POLICY "Managers and admins can insert units"
  ON units FOR INSERT TO authenticated WITH CHECK (true);

-- Managers and admins can update units
CREATE POLICY "Managers and admins can update units"
  ON units FOR UPDATE TO authenticated USING (true);

-- Seed default units
INSERT INTO units (name) VALUES
  ('KT11'), ('150A'), ('14A'), ('LC03'),
  ('IR B1506'), ('IR B1631'), ('IR B1913B'), ('IR A2109'),
  ('CL B0207'), ('BR B2305'), ('AR C3706'), ('AR D1503'),
  ('SH P0403'), ('AC 1025'), ('ACc 1027'), ('34F'), ('MP Office')
ON CONFLICT (name) DO NOTHING;
