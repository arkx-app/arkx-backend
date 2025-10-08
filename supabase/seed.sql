-- seed.sql
-- Purpose: populate basic test data for Arkx backend
-- Run with: supabase db reset  OR  psql -f seed.sql

-- =========================================================
-- Idempotent inserts: only insert if table is empty
-- =========================================================

DO $$
DECLARE
  odoo_provider_id uuid;
  microsoft_provider_id uuid;
  sap_provider_id uuid;
BEGIN
  -- ========== user_provider (insert first) ==========
  IF NOT EXISTS (SELECT 1 FROM public.user_provider LIMIT 1) THEN
    INSERT INTO public.user_provider (company_name, contact_name, email, website, phone, headquarters, product_focus, description)
    VALUES
      ('Odoo S.A.', 'Fabien Pinckaers', 'partners@odoo.com', 'https://odoo.com', '+32 81 81 37 00', 'Belgium', 'Odoo ERP Suite', 'Open-source ERP and CRM platform.'),
      ('Microsoft', 'Satya Nadella', 'partners@microsoft.com', 'https://microsoft.com', '+1 425 882 8080', 'USA', 'Dynamics 365', 'Enterprise cloud-based ERP and CRM suite.'),
      ('SAP SE', 'Christian Klein', 'partners@sap.com', 'https://sap.com', '+49 6227 747474', 'Germany', 'SAP Business One / ByDesign', 'Global ERP and SCM platform.');
  END IF;

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
-- Confirmation output (optional)
-- =========================================================
DO $$
DECLARE
  c_count int;
  p_count int;
  v_count int;
BEGIN
  SELECT COUNT(*) INTO c_count FROM public.user_client;
  SELECT COUNT(*) INTO p_count FROM public.user_partner;
  SELECT COUNT(*) INTO v_count FROM public.user_provider;

  RAISE NOTICE 'Seed completed: % clients, % partners, % providers', c_count, p_count, v_count;
END $$;