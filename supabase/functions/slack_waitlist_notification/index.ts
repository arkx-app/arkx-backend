import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

interface PartnerWaitlistRecord {
    id: string;
    email: string;
    company_name: string;
    phone_number: string;
    website: string;
    odoo_partner_url: string | null;
    created_at: string | null;
    updated_at: string | null;
}

interface SlackMessage {
    text: string;
}

serve(async (req: Request) => {
    try {
        // Get Slack webhook URL from environment
        const slackWebhookUrl = Deno.env.get("SLACK_WEBHOOK_URL");

        if (!slackWebhookUrl) {
            console.error("SLACK_WEBHOOK_URL environment variable is not set");
            return new Response(
                JSON.stringify({ error: "Slack webhook URL not configured" }),
                {
                    status: 500,
                    headers: { "Content-Type": "application/json" },
                },
            );
        }

        // Parse the request body
        const body = await req.json();
        const record: PartnerWaitlistRecord = body.record;

        if (!record) {
            return new Response(
                JSON.stringify({ error: "No record data provided" }),
                {
                    status: 400,
                    headers: { "Content-Type": "application/json" },
                },
            );
        }

        // Determine if this is an insert or update
        const eventType = body.type || "INSERT";
        const isUpdate = eventType === "UPDATE";

        // Format the Slack message
        const messageText = isUpdate
            ? `🔄 *Partner Waitlist Entry Updated*\n\n`
            : `✨ *New Partner Waitlist Entry*\n\n`;

        const slackMessage: SlackMessage = {
            text:
                `${messageText}*Company:* ${record.company_name}\n*Email:* ${record.email}\n*Phone:* ${record.phone_number}\n*Website:* ${record.website}${
                    record.odoo_partner_url
                        ? `\n*Odoo Partner URL:* ${record.odoo_partner_url}`
                        : ""
                }\n*ID:* ${record.id}${
                    record.created_at
                        ? `\n*Created:* ${
                            new Date(record.created_at).toLocaleString()
                        }`
                        : ""
                }${
                    record.updated_at
                        ? `\n*Updated:* ${
                            new Date(record.updated_at).toLocaleString()
                        }`
                        : ""
                }`,
        };

        // Send message to Slack
        const slackResponse = await fetch(slackWebhookUrl, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(slackMessage),
        });

        if (!slackResponse.ok) {
            const errorText = await slackResponse.text();
            console.error("Failed to send Slack notification:", errorText);
            return new Response(
                JSON.stringify({
                    error: `Failed to send Slack notification: ${errorText}`,
                }),
                {
                    status: 500,
                    headers: { "Content-Type": "application/json" },
                },
            );
        }

        return new Response(
            JSON.stringify({
                success: true,
                message: "Slack notification sent successfully",
            }),
            { status: 200, headers: { "Content-Type": "application/json" } },
        );
    } catch (error) {
        console.error("Error processing request:", error);
        const errorMessage = error instanceof Error
            ? error.message
            : "Internal server error";
        return new Response(
            JSON.stringify({ error: errorMessage }),
            { status: 500, headers: { "Content-Type": "application/json" } },
        );
    }
});
