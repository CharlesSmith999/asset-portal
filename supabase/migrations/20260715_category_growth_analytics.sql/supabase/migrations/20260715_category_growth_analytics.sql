-- Stores category totals whenever a user saves a net-worth snapshot.
-- Historical category values were not present in the imported workbook, so this
-- table begins building category-growth history from the next saved snapshot.
create table if not exists public.net_worth_category_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  snapshot_date date not null,
  category text not null,
  total_value numeric not null default 0 check (total_value >= 0),
  currency text not null default 'PKR' check (currency in ('PKR', 'USD')),
  created_at timestamptz not null default now(),
  unique (user_id, snapshot_date, category, currency)
);

alter table public.net_worth_category_snapshots enable row level security;

drop policy if exists "users manage own category snapshots" on public.net_worth_category_snapshots;
create policy "users manage own category snapshots"
on public.net_worth_category_snapshots for all to authenticated
using (user_id = auth.uid()) with check (user_id = auth.uid());
