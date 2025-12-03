# arkx-backend

## Supabase Edge Functions

### Slack Waitlist Notification

The `slack_waitlist_notification` edge function sends Slack notifications when rows are inserted or updated in the `partner_waitlist` table.

#### Setup

1. **Set the Slack Webhook URL secret:**

   For local development, create a `.env.local` file in the project root:
   ```bash
   echo 'SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"' > .env.local
   ```

   Or set it directly when serving:
   ```bash
   SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL" supabase functions serve slack_waitlist_notification --no-verify-jwt
   ```

   For production:
   ```bash
   supabase secrets set SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL" --project-ref your-project-ref
   ```

2. **Run the edge function locally:**

   ```bash
   supabase functions serve slack_waitlist_notification --no-verify-jwt
   ```

   The function will be available at: `http://127.0.0.1:54321/functions/v1/slack_waitlist_notification`

3. **Test the edge function locally:**

   ```bash
   curl -X POST http://127.0.0.1:54321/functions/v1/slack_waitlist_notification \
     -H "Content-Type: application/json" \
     -d '{
       "type": "INSERT",
       "record": {
         "id": "test-123",
         "email": "test@example.com",
         "company_name": "Test Company",
         "phone_number": "+1234567890",
         "website": "https://test.com",
         "odoo_partner_url": null,
         "created_at": "2024-12-03T10:00:00Z",
         "updated_at": null
       }
     }'
   ```

4. **Deploy the edge function to production:**

   ```bash
   supabase functions deploy slack_waitlist_notification
   ```

3. **Configure the edge function URL (for production):**

   The database trigger needs to know the edge function URL. For local development, it defaults to `http://127.0.0.1:54321/functions/v1/slack_waitlist_notification`.

   For production, run this SQL command in your Supabase SQL editor:
   ```sql
   ALTER DATABASE postgres SET app.settings.edge_function_url = 'https://[your-project-ref].supabase.co/functions/v1/slack_waitlist_notification';
   ```

4. **Optional: Configure service role key for authentication:**

   If you want to add authentication to the edge function calls from the database trigger:
   ```sql
   ALTER DATABASE postgres SET app.settings.service_role_key = '[your-service-role-key]';
   ```

#### How it works

- Database triggers on `partner_waitlist` table (INSERT and UPDATE) call the edge function via `pg_net` extension
- The edge function receives the record data and formats a Slack message
- The message is sent to Slack using the configured webhook URL
- All fields from the `partner_waitlist` table are included in the notification
