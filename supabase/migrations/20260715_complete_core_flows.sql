-- Ledgerly: complete ownership, payment lifecycle, and safe sharing flows.
-- Run this after 20260714_family_asset_sharing.sql in the Supabase SQL Editor.
-- Existing single-admin liability and installment rows are assigned to the admin.

alter table public.liabilities add column if not exists user_id uuid references auth.users(id) on delete cascade;
alter table public.installments add column if not exists user_id uuid references auth.users(id) on delete cascade;

update public.liabilities
set user_id = (select id from public.profiles where role = 'admin' order by id limit 1)
where user_id is null;

update public.installments
set user_id = (select id from public.profiles where role = 'admin' order by id limit 1)
where user_id is null;

alter table public.liabilities alter column user_id set not null;
alter table public.installments alter column user_id set not null;

alter table public.liabilities enable row level security;
alter table public.installments enable row level security;
alter table public.user_settings enable row level security;

-- Remove only the portal's named policies. Review and remove any older permissive
-- policies in your project before production.
drop policy if exists "users manage own liabilities" on public.liabilities;
drop policy if exists "users manage own installments" on public.installments;
drop policy if exists "users manage own settings" on public.user_settings;

create policy "users manage own liabilities"
on public.liabilities for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users manage own installments"
on public.installments for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users manage own settings"
on public.user_settings for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

-- A shared asset is readable but remains editable only by its owner or an admin.
-- The asset policies are created by the family-sharing migration.
