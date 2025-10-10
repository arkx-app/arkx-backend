-- 03_user_partner.sql
-- Purpose: Seed data for user_partner table
-- Description: Populates basic test data for partners/implementers offering services
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

  -- ========== user_partner ==========
  IF NOT EXISTS (SELECT 1 FROM public.user_partner LIMIT 1) THEN
    INSERT INTO public.user_partner (company_name, contact_name, email, website, phone, country, specialization, certifications, description, provider_id)
    VALUES
      ('NextWave Consulting', 'Jan Peeters', 'jan@nextwave.io', 'https://nextwave.io', '+32 498 222 333', 'Belgium', 'ERP Implementation', ARRAY['Odoo Certified', 'SAP Bronze Partner'], 'Specialists in digital transformation for SMEs.', odoo_provider_id),
      ('Nordic Systems', 'Karin Olsen', 'karin@nordicsys.dk', 'https://nordicsys.dk', '+45 211 456 789', 'Denmark', 'CRM & Marketing Automation', ARRAY['HubSpot Certified'], 'Helping mid-size companies integrate CRM and marketing platforms.', microsoft_provider_id),
      ('CloudBridge Partners', 'James Liu', 'james@cloudbridge.eu', 'https://cloudbridge.eu', '+44 731 456 120', 'UK', 'Multi-platform Integrations', ARRAY['Microsoft Partner Silver'], 'Integration experts across ERP, HR, and finance systems.', sap_provider_id);
  END IF;
END $$;

-- =========================================================
-- Confirmation output
-- =========================================================
DO $$
DECLARE
  p_count int;
BEGIN
  SELECT COUNT(*) INTO p_count FROM public.user_partner;
  RAISE NOTICE 'Partner seed completed: % partners', p_count;
END $$;

