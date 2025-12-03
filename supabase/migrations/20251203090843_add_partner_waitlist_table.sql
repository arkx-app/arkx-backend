-- 20251203T090843_add_partner_waitlist_table.sql
-- Migration: Create partner_waitlist table
-- Description: Adds partner_waitlist table for storing waitlist entries
-- Author: rubenlauwaert
-- ------------------------------------------------------------

-- ========================
-- partner_waitlist
-- ========================
CREATE TABLE IF NOT EXISTS public.partner_waitlist (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email             text NOT NULL UNIQUE,
    company_name      text NOT NULL,
    phone_number      text NOT NULL,
    website           text NOT NULL,
    odoo_partner_url  text,
    created_at        timestamptz DEFAULT now(),
    updated_at        timestamptz DEFAULT now()
);

COMMENT ON TABLE public.partner_waitlist IS 'Waitlist for partners interested in joining the platform.';

-- ========================
-- Indexes for performance
-- ========================
-- Note: Unique constraint on email automatically creates a unique index

-- ========================
-- Updated_at trigger
-- ========================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_partner_waitlist_updated_at') THEN
    CREATE TRIGGER trg_partner_waitlist_updated_at
    BEFORE UPDATE ON public.partner_waitlist
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- ========================
-- Row Level Security (RLS)
-- ========================
ALTER TABLE public.partner_waitlist ENABLE ROW LEVEL SECURITY;

-- Allow public to insert (anyone can join the waitlist)
CREATE POLICY "Allow public insert on partner_waitlist"
ON public.partner_waitlist
FOR INSERT
TO public
WITH CHECK (true);

-- Allow authenticated users to read all waitlist entries
CREATE POLICY "Allow authenticated users to read partner_waitlist"
ON public.partner_waitlist
FOR SELECT
TO authenticated
USING (true);

-- Allow service role (admins) to update
CREATE POLICY "Allow service role to update partner_waitlist"
ON public.partner_waitlist
FOR UPDATE
TO service_role
USING (true)
WITH CHECK (true);

-- Allow service role (admins) to delete
CREATE POLICY "Allow service role to delete partner_waitlist"
ON public.partner_waitlist
FOR DELETE
TO service_role
USING (true);

-- ========================
-- End of migration
-- ========================

