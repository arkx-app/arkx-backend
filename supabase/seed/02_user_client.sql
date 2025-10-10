-- 02_user_client.sql
-- Purpose: Seed data for user_client table
-- Description: Populates basic test data for clients seeking software partners
-- Dependencies: Requires user_provider table to be seeded first

-- =========================================================
-- Idempotent inserts: only insert if table is empty
-- =========================================================

DO $$
DECLARE
  odoo_provider_id uuid;
  microsoft_provider_id uuid;
  sap_provider_id uuid;
BEGIN
  -- Get provider IDs for relationships
  SELECT id INTO odoo_provider_id FROM public.user_provider WHERE company_name = 'Odoo S.A.';
  SELECT id INTO microsoft_provider_id FROM public.user_provider WHERE company_name = 'Microsoft';
  SELECT id INTO sap_provider_id FROM public.user_provider WHERE company_name = 'SAP SE';

  -- ========== user_client ==========
  IF NOT EXISTS (SELECT 1 FROM public.user_client LIMIT 1) THEN
    INSERT INTO public.user_client (company_name, contact_name, email, phone, country, industry, project_brief, provider_id)
    VALUES
      ('BrightPath Logistics', 'Emma Verhoeven', 'emma@brightpath.io', '+32 471 123 456', 'Belgium', 'Logistics', 'Looking for an ERP system for warehouse management.', odoo_provider_id),
      ('TechNova', 'Oliver Janssen', 'oliver@technova.be', '+32 479 987 654', 'Belgium', 'IT Services', 'Need CRM and invoicing integration for our consulting teams.', microsoft_provider_id),
      ('BlueCrest Retail', 'Lara Dupont', 'lara@bluecrest.eu', '+33 612 456 789', 'France', 'Retail', 'Interested in an omnichannel retail management platform.', sap_provider_id);
  END IF;
END $$;

-- =========================================================
-- Confirmation output
-- =========================================================
DO $$
DECLARE
  c_count int;
BEGIN
  SELECT COUNT(*) INTO c_count FROM public.user_client;
  RAISE NOTICE 'Client seed completed: % clients', c_count;
END $$;

