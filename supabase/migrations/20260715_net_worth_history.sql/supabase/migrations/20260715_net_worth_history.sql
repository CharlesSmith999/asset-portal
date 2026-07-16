-- Ledgerly: historical net-worth snapshots.
-- Stores portfolio totals at a point in time. Asset-level history remains in the original workbook.

create table if not exists public.net_worth_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  snapshot_date date not null,
  asset_total numeric not null default 0 check (asset_total >= 0),
  liability_total numeric not null default 0 check (liability_total >= 0),
  currency text not null default 'PKR' check (currency in ('PKR','USD')),
  source text not null default 'Manual snapshot',
  created_at timestamptz not null default now(),
  unique (user_id, snapshot_date, currency)
);

alter table public.net_worth_snapshots enable row level security;

drop policy if exists "users manage own net worth snapshots" on public.net_worth_snapshots;
create policy "users manage own net worth snapshots"
on public.net_worth_snapshots for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

-- Historical totals imported from Building an Emergency Fund-Play.xlsx.
-- June and January 2025 are blank/incomplete in the source. Their totals are carried
-- forward from the immediately prior recorded month at the owner's request.
insert into public.net_worth_snapshots (user_id, snapshot_date, asset_total, liability_total, currency, source)
values
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2024-04-30', 23679466.00, 0, 'PKR', 'Imported from portfolio workbook'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2024-05-31', 24386503.00, 0, 'PKR', 'Imported from portfolio workbook'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2024-06-30', 24386503.00, 0, 'PKR', 'Carried forward from May 2024'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2024-07-31', 26755927.35, 0, 'PKR', 'Imported from portfolio workbook'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2024-08-31', 28629707.06, 0, 'PKR', 'Imported from portfolio workbook'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2024-09-30', 29690880.78, 0, 'PKR', 'Imported from portfolio workbook'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2024-10-31', 34572004.00, 0, 'PKR', 'Imported from portfolio workbook'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2024-11-30', 34906514.33, 0, 'PKR', 'Imported from portfolio workbook'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2024-12-31', 36338285.73, 0, 'PKR', 'Imported from portfolio workbook'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2025-01-31', 36338285.73, 0, 'PKR', 'Carried forward from December 2024'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2025-02-28', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2025-03-31', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2025-04-30', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2025-05-31', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2025-06-30', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2025-07-31', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2025-08-31', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2025-09-30', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2025-10-31', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2025-11-30', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2025-12-31', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2026-01-31', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2026-02-28', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2026-03-31', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2026-04-30', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2026-05-31', 36338285.73, 0, 'PKR', 'Carried forward from previous month'),
  ('81407d8e-924e-4502-a692-6a29e3b66949', '2026-06-30', 36338285.73, 0, 'PKR', 'Carried forward from previous month')
on conflict (user_id, snapshot_date, currency) do update
set asset_total = excluded.asset_total,
    liability_total = excluded.liability_total,
    source = excluded.source;
