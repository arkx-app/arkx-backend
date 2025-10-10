-- 01_user_provider.sql
-- Purpose: Seed data for user_provider table
-- Description: Populates basic test data for software providers/vendors
-- Dependencies: None (seeded first due to foreign key relationships)

-- =========================================================
-- Idempotent inserts: only insert if table is empty
-- =========================================================

DO $$
BEGIN
  -- ========== user_provider (insert first) ==========
  IF NOT EXISTS (SELECT 1 FROM public.user_provider LIMIT 1) THEN
    INSERT INTO public.user_provider (company_name, contact_name, email, website, phone, headquarters, product_focus, description)
    VALUES
      ('Odoo S.A.', 'Fabien Pinckaers', 'partners@odoo.com', 'https://odoo.com', '+32 81 81 37 00', 'Belgium', 'Odoo ERP Suite', 'Open-source ERP and CRM platform.'),
      ('Microsoft', 'Satya Nadella', 'partners@microsoft.com', 'https://microsoft.com', '+1 425 882 8080', 'USA', 'Dynamics 365', 'Enterprise cloud-based ERP and CRM suite.'),
      ('SAP SE', 'Christian Klein', 'partners@sap.com', 'https://sap.com', '+49 6227 747474', 'Germany', 'SAP Business One / ByDesign', 'Global ERP and SCM platform.');
  END IF;
END $$;

-- =========================================================
-- Confirmation output
-- =========================================================
DO $$
DECLARE
  v_count int;
BEGIN
  SELECT COUNT(*) INTO v_count FROM public.user_provider;
  RAISE NOTICE 'Provider seed completed: % providers', v_count;
END $$;

