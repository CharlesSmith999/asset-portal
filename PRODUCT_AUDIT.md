# Ledgerly product audit

## Product outcome

Ledgerly should answer three questions reliably for every signed-in person:

1. What do I own, and what can I view because it was shared with me?
2. What do I owe, and what must I pay next?
3. Who can view each asset, and what can they change?

## Gaps found in the previous build

| Area | Gap | Product risk | Resolution in this release |
| --- | --- | --- | --- |
| Data ownership | Liabilities and installments were not consistently tied to a user. | A family member could receive another person's obligations. | Adds `user_id`, row-level security, and user-scoped saves/loads. |
| Shared assets | A shared viewer was offered a Remove control. | Confusing and could produce failed actions. | Shared holdings are labelled view-only; only owners/admins can edit or remove. |
| Payment lifecycle | A payment could be listed but not completed. | Due dates become stale and reminders lose value. | Adds **Mark paid**, which moves recurring due dates forward and archives one-time items. |
| Price refresh | Refreshed prices lived only in the browser; crypto calculation was incorrect. | Values changed back after refresh and could be wrong. | Corrects unit pricing and saves owned live prices to Supabase. |
| Editing | Records could be added or removed but not corrected. | Users resort to deleting/recreating financial records. | Adds edit flows for assets, liabilities, and installments. |
| Demo state | Sample data could be mistaken for stored personal data. | Trust and data-quality risk. | Keeps sample data explicitly local and labelled; real records replace it after the first save/reload. |
| Reminders | Preferences were saved but the dashboard did not use the selected notice period. | UI promise did not match behaviour. | Uses the saved notice period for due-soon calculations and labels email delivery accurately. |
| Family access | “Add person” was presented as an invitation even though it did not send one. | Users expect an email that is never sent. | Uses the accurate **pending member** state; sign-in activation is explained in-product. |
| Email delivery | No server-side scheduler or provider integration existed. | No emails can be sent securely from a static site. | Left intentionally server-side; documented as the remaining deployment task. |

## Finished user flows

### Administrator

1. Sign in.
2. Add, edit, or remove owned assets, liabilities, and payment schedules.
3. Add a family member; their status is pending until first sign-in.
4. Tag an owned asset with an active family member.
5. Mark a scheduled payment paid; recurring schedules advance automatically.
6. Refresh live prices; owned live-priced assets are saved back to the database.

### Family member

1. Sign in using the email recorded by the administrator.
2. View own assets plus assets explicitly shared with them.
3. Add and manage only their own assets, liabilities, and schedules.
4. View shared assets as read-only.

## Remaining deliberate boundary

Automated emails require a server-side scheduled job and an email provider. A GitHub Pages site must not contain the email API key. The portal now handles the preference and in-portal due state; a Supabase Edge Function plus scheduled invocation is the correct next production step.

## Acceptance checks

- A member cannot load, alter, or delete another member's liabilities or schedules.
- A member can only view an asset when they own it or the administrator shared it.
- Completing a monthly, quarterly, or yearly payment advances its next due date correctly.
- Refreshing a supported price persists it for the owner.
- The dashboard distinguishes owned value from view-only shared value.
