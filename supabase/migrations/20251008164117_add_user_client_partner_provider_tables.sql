-- 20251008T150000_create_user_tables.sql
-- Migration: Create base user tables for Arkx
-- Description: Adds user_client, user_partner, and user_provider tables
-- Author: rubenlauwaert
-- ------------------------------------------------------------

-- Drop tables if re-running locally (not for prod!)
-- DO $$ BEGIN
--   DROP TABLE IF EXISTS user_client, user_partner, user_provider CASCADE;
-- EXCEPTION WHEN others THEN NULL;
-- END $$;

-- ========================
-- user_client
-- ========================
CREATE TABLE IF NOT EXISTS public.user_client (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id      uuid REFERENCES auth.users(id) ON DELETE SET NULL,
    company_name      text NOT NULL,
    contact_name      text,
    email             text NOT NULL,
    phone             text,
    country           text,
    industry          text,
    project_brief     text,
    created_at        timestamptz DEFAULT now(),
    updated_at        timestamptz DEFAULT now()
);

COMMENT ON TABLE public.user_client IS 'Clients seeking software partners via Arkx.';
COMMENT ON COLUMN public.user_client.auth_user_id IS 'Reference to Supabase Auth user.';


-- ========================
-- user_partner
-- ========================
CREATE TABLE IF NOT EXISTS public.user_partner (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id      uuid REFERENCES auth.users(id) ON DELETE SET NULL,
    company_name      text NOT NULL,
    contact_name      text,
    email             text NOT NULL,
    website           text,
    phone             text,
    country           text,
    specialization    text,     -- e.g. ERP, CRM, etc.
    certifications    text[],   -- list of vendor certifications
    description       text,
    created_at        timestamptz DEFAULT now(),
    updated_at        timestamptz DEFAULT now()
);

COMMENT ON TABLE public.user_partner IS 'Partners / implementers that offer configuration or integration services.';


-- ========================
-- user_provider
-- ========================
CREATE TABLE IF NOT EXISTS public.user_provider (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id      uuid REFERENCES auth.users(id) ON DELETE SET NULL,
    company_name      text NOT NULL,
    contact_name      text,
    email             text NOT NULL,
    website           text,
    phone             text,
    headquarters      text,
    product_focus     text,     -- e.g. "Odoo", "SAP", "Dynamics"
    description       text,
    created_at        timestamptz DEFAULT now(),
    updated_at        timestamptz DEFAULT now()
);

COMMENT ON TABLE public.user_provider IS 'Software vendors / providers showcasing their partner ecosystems.';


-- ========================
-- Indexes for performance
-- ========================
CREATE INDEX IF NOT EXISTS idx_user_client_email     ON public.user_client (email);
CREATE INDEX IF NOT EXISTS idx_user_partner_email    ON public.user_partner (email);
CREATE INDEX IF NOT EXISTS idx_user_provider_email   ON public.user_provider (email);

-- ========================
-- Updated_at trigger
-- ========================
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_user_client_updated_at') THEN
    CREATE TRIGGER trg_user_client_updated_at
    BEFORE UPDATE ON public.user_client
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_user_partner_updated_at') THEN
    CREATE TRIGGER trg_user_partner_updated_at
    BEFORE UPDATE ON public.user_partner
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_user_provider_updated_at') THEN
    CREATE TRIGGER trg_user_provider_updated_at
    BEFORE UPDATE ON public.user_provider
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- ========================
-- End of migration
-- ========================