# Ledgerly — Personal Wealth Portal

Ledgerly is a private wealth portal for tracking assets, liabilities, insurance premiums, and payment due dates in PKR and USD.

Live portal: https://charlessmith999.github.io/asset-portal/

## What it does

- Tracks stocks (including AKD and KTrade), crypto, commodities, real estate, mutual funds, and provident funds.
- Tracks liabilities and insurance premiums, including monthly, quarterly, yearly, and one-time payments.
- Shows due-soon and overdue payment information on the dashboard.
- Refreshes supported crypto prices from CoinGecko and stock prices from Yahoo Finance.
- Uses Supabase authentication for password or secure-email-link sign-in.
- Lets a portal administrator change their password and log out.
- Lets the administrator add family members, set a relationship, and tag individual assets for each member.
- Gives each invited member a dashboard containing their own assets plus only the assets tagged for them. Members can add their own assets.
- Lets owners edit records, complete an installment, and automatically advance recurring due dates.
- Persists refreshed live prices for the asset owner, rather than keeping the new price only in the browser.

## Access model

There are two types of people:

1. **Administrator** — manages members, sees all assets, and can tag any asset.
2. **Member** — signs in using their invited email address; sees assets they own and assets specifically tagged for them.

To share an asset:

1. Open **People & access** and add the person’s name, email, and relationship.
2. Ask them to sign in once using that same email address.
3. Go to **Assets**, choose **TAG** on the asset, and enter their email.

An email cannot see portal data unless it has been added by the administrator. Adding a person creates a **pending member**; they become active when they first sign in using the same email address.

## Technical setup

- Frontend: a static `index.html` hosted on GitHub Pages.
- Database and authentication: Supabase.
- Database sharing migration: [supabase/migrations/20260714_family_asset_sharing.sql](supabase/migrations/20260714_family_asset_sharing.sql).
- Core-flow and ownership migration: [supabase/migrations/20260715_complete_core_flows.sql](supabase/migrations/20260715_complete_core_flows.sql).
- Product audit and completed-flow checklist: [PRODUCT_AUDIT.md](PRODUCT_AUDIT.md).

The public Supabase URL and publishable key are configured in `index.html`. Do not place database passwords, service-role keys, or email-provider secrets in this repository or the browser.

## Database setup

The project requires the existing Supabase tables for profiles, assets, liabilities, installments, and user settings. The sharing migration adds `portal_members` and `asset_shares`, configures row-level security, and links an invited member to their account on first sign-in.

To recreate the sharing setup in another Supabase project:

1. Create the core portal tables.
2. Run the family-sharing migration in the Supabase SQL Editor.
3. Run the core-flow and ownership migration in the Supabase SQL Editor.
4. Set the administrator’s `profiles.role` to `admin`.
5. Configure Supabase Auth email redirects for the deployed portal URL.

The second migration assigns any existing liability or installment rows to the first administrator profile. Review this before running it if the database already contains multiple users.

## Reminders and email

The portal stores reminder preferences, uses the selected notice period for in-portal due states, and can advance recurring due dates when a payment is marked paid. Automated scheduled emails still require a secure server-side job (for example, a Supabase Edge Function plus a scheduler) and an email provider. Email-provider API keys must remain server-side.

## Local preview

Open `index.html` in a modern browser. For authentication and database features, use the configured Supabase project and access the portal through its deployed HTTPS URL.
