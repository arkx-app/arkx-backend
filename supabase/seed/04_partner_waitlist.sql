-- 04_partner_waitlist.sql
-- Purpose: Seed data for partner_waitlist table
-- Description: Populates basic test data for partner waitlist entries
-- Dependencies: None

-- =========================================================
-- Idempotent inserts: only insert if table is empty
-- =========================================================

DO $$
BEGIN
  -- ========== partner_waitlist ==========
  IF NOT EXISTS (SELECT 1 FROM public.partner_waitlist LIMIT 1) THEN
    INSERT INTO public.partner_waitlist (email, company_name, phone_number, website, odoo_partner_url)
    VALUES
      ('info@techsolutions.be', 'TechSolutions Belgium', '+32 2 123 4567', 'https://techsolutions.be', 'https://www.odoo.com/partners/techsolutions-be'),
      ('contact@digitalworks.eu', 'Digital Works Europe', '+33 1 234 5678', 'https://digitalworks.eu', NULL),
      ('hello@cloudintegrators.nl', 'Cloud Integrators BV', '+31 20 987 6543', 'https://cloudintegrators.nl', 'https://www.odoo.com/partners/cloudintegrators'),
      ('info@erpexperts.de', 'ERP Experts GmbH', '+49 30 555 1234', 'https://erpexperts.de', NULL),
      ('team@bizautomation.co.uk', 'Business Automation Ltd', '+44 20 7890 1234', 'https://bizautomation.co.uk', 'https://www.odoo.com/partners/bizautomation');
  END IF;
END $$;

-- =========================================================
-- Confirmation output
-- =========================================================
DO $$
DECLARE
  w_count int;
BEGIN
  SELECT COUNT(*) INTO w_count FROM public.partner_waitlist;
  RAISE NOTICE 'Partner waitlist seed completed: % entries', w_count;
END $$;

