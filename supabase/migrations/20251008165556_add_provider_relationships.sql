-- 20250109T000000_add_provider_relationships.sql
-- Migration: Add provider relationships to user_client and user_partner tables
-- Description: Establishes foreign key relationships between clients/partners and providers
-- Author: rubenlauwaert
-- ------------------------------------------------------------

-- ========================
-- Add provider relationships
-- ========================

-- Add provider_id column to user_client table
ALTER TABLE public.user_client 
ADD COLUMN provider_id uuid NOT NULL REFERENCES public.user_provider(id) ON DELETE RESTRICT;

-- Add provider_id column to user_partner table  
ALTER TABLE public.user_partner 
ADD COLUMN provider_id uuid NOT NULL REFERENCES public.user_provider(id) ON DELETE RESTRICT;

-- ========================
-- Add indexes for performance
-- ========================
CREATE INDEX IF NOT EXISTS idx_user_client_provider_id ON public.user_client (provider_id);
CREATE INDEX IF NOT EXISTS idx_user_partner_provider_id ON public.user_partner (provider_id);

-- ========================
-- Add comments for documentation
-- ========================
COMMENT ON COLUMN public.user_client.provider_id IS 'Reference to the software provider this client is interested in.';
COMMENT ON COLUMN public.user_partner.provider_id IS 'Reference to the software provider this partner specializes in.';

-- ========================
-- End of migration
-- ========================
