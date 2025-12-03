-- 20251203T101344_add_slack_notification_trigger.sql
-- Migration: Add Slack notification trigger for partner_waitlist table
-- Description: Creates database triggers that call the slack_waitlist_notification edge function on INSERT and UPDATE
-- Author: rubenlauwaert
-- ------------------------------------------------------------

-- ========================
-- Enable pg_net extension for making HTTP requests
-- ========================
CREATE EXTENSION IF NOT EXISTS pg_net;

-- ========================
-- Function to call Slack notification edge function
-- ========================
CREATE OR REPLACE FUNCTION public.notify_slack_waitlist()
RETURNS TRIGGER AS $$
DECLARE
  edge_function_url text;
  payload jsonb;
  request_id bigint;
  service_role_key text;
  headers jsonb;
BEGIN
  -- Construct the edge function URL
  -- For local development: Use host.docker.internal to reach the host from inside the container
  -- For production: https://[project-ref].supabase.co/functions/v1/slack_waitlist_notification
  -- Note: Update this URL for production deployment
  edge_function_url := current_setting('app.settings.edge_function_url', true);
  
  -- Fallback to local URL if not configured
  -- Use host.docker.internal on Mac/Windows, or host network IP on Linux
  IF edge_function_url IS NULL OR edge_function_url = '' THEN
    edge_function_url := 'http://host.docker.internal:54321/functions/v1/slack_waitlist_notification';
  END IF;

  -- Get service role key if configured (optional, for authentication)
  service_role_key := current_setting('app.settings.service_role_key', true);

  -- Determine event type
  IF TG_OP = 'INSERT' THEN
    payload := jsonb_build_object(
      'type', 'INSERT',
      'record', to_jsonb(NEW)
    );
  ELSIF TG_OP = 'UPDATE' THEN
    payload := jsonb_build_object(
      'type', 'UPDATE',
      'record', to_jsonb(NEW),
      'old_record', to_jsonb(OLD)
    );
  END IF;

  -- Build headers
  headers := jsonb_build_object('Content-Type', 'application/json');
  IF service_role_key IS NOT NULL AND service_role_key != '' THEN
    headers := headers || jsonb_build_object('Authorization', 'Bearer ' || service_role_key);
  END IF;

  -- Call the edge function asynchronously using pg_net
  -- net.http_post returns a request_id (bigint) for async requests
  -- The actual HTTP request happens in the background
  BEGIN
    -- Ensure pg_net worker is running
    PERFORM net.wake();
    
    -- Log the attempt
    RAISE NOTICE 'Calling edge function at: %', edge_function_url;
    
    SELECT net.http_post(
      url := edge_function_url,
      body := payload,
      headers := headers
    ) INTO request_id;
    
    RAISE NOTICE 'HTTP request queued with ID: %', request_id;
  EXCEPTION WHEN OTHERS THEN
    -- Log error but don't fail the transaction
    RAISE WARNING 'Error calling Slack notification edge function: %', SQLERRM;
  END;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.notify_slack_waitlist() IS 'Calls the slack_waitlist_notification edge function when partner_waitlist rows are inserted or updated.';

-- ========================
-- Create triggers
-- ========================
DROP TRIGGER IF EXISTS trg_partner_waitlist_slack_notification_insert ON public.partner_waitlist;
CREATE TRIGGER trg_partner_waitlist_slack_notification_insert
  AFTER INSERT ON public.partner_waitlist
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_slack_waitlist();

DROP TRIGGER IF EXISTS trg_partner_waitlist_slack_notification_update ON public.partner_waitlist;
CREATE TRIGGER trg_partner_waitlist_slack_notification_update
  AFTER UPDATE ON public.partner_waitlist
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_slack_waitlist();

-- ========================
-- Configuration instructions
-- ========================
-- To configure the edge function URL for production, run:
-- ALTER DATABASE postgres SET app.settings.edge_function_url = 'https://[project-ref].supabase.co/functions/v1/slack_waitlist_notification';
--
-- To configure the service role key for authentication (optional, but recommended):
-- ALTER DATABASE postgres SET app.settings.service_role_key = '[your-service-role-key]';
--
-- Note: For local development, the default URL (http://host.docker.internal:54321/functions/v1/slack_waitlist_notification) will be used.
-- This allows the database container to reach the edge function running on the host machine.

-- ========================
-- End of migration
-- ========================

