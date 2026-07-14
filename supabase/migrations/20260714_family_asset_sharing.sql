-- Ledgerly: family member access and asset-level sharing
-- Prerequisite: profiles and assets tables already exist.
-- Run in the Supabase SQL Editor or through the Supabase CLI.

create table if not exists public.portal_members (
  id uuid primary key default gen_random_uuid(),
  email text not null unique check (email = lower(email)),
  display_name text not null,
  relationship text not null default 'Family',
  active boolean not null default true,
  user_id uuid unique references auth.users(id) on delete set null,
  added_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.asset_shares (
  asset_id uuid not null references public.assets(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  relationship text,
  created_at timestamptz not null default now(),
  primary key (asset_id, user_id)
);

alter table public.portal_members enable row level security;
alter table public.asset_shares enable row level security;

create or replace function public.is_portal_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

create or replace function public.is_portal_member()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_portal_admin()
    or exists (
      select 1 from public.portal_members
      where user_id = auth.uid() and active = true
    );
$$;

-- Links an invited email to the auth account on the person’s first sign-in.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if lower(new.email) = 'charlestsmith999@gmail.com' then
    insert into public.profiles (id, email, role)
    values (new.id, lower(new.email), 'admin')
    on conflict (id) do update set email = excluded.email, role = 'admin';
  elsif exists (
    select 1 from public.portal_members
    where email = lower(new.email) and active = true
  ) then
    insert into public.profiles (id, email, role)
    values (new.id, lower(new.email), 'member')
    on conflict (id) do update set email = excluded.email;

    update public.portal_members
    set user_id = new.id
    where email = lower(new.email);
  end if;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Recreate policies so the migration is repeatable.
drop policy if exists "admins manage portal members" on public.portal_members;
drop policy if exists "admins manage asset shares" on public.asset_shares;
drop policy if exists "members view accessible assets" on public.assets;
drop policy if exists "members add their own assets" on public.assets;
drop policy if exists "owners or admins update assets" on public.assets;
drop policy if exists "owners or admins delete assets" on public.assets;

create policy "admins manage portal members"
on public.portal_members for all
to authenticated
using (public.is_portal_admin())
with check (public.is_portal_admin());

create policy "admins manage asset shares"
on public.asset_shares for all
to authenticated
using (public.is_portal_admin())
with check (public.is_portal_admin());

create policy "members view accessible assets"
on public.assets for select
to authenticated
using (
  public.is_portal_admin()
  or user_id = auth.uid()
  or exists (
    select 1 from public.asset_shares
    where asset_id = assets.id and user_id = auth.uid()
  )
);

create policy "members add their own assets"
on public.assets for insert
to authenticated
with check (public.is_portal_member() and user_id = auth.uid());

create policy "owners or admins update assets"
on public.assets for update
to authenticated
using (public.is_portal_admin() or user_id = auth.uid())
with check (public.is_portal_admin() or user_id = auth.uid());

create policy "owners or admins delete assets"
on public.assets for delete
to authenticated
using (public.is_portal_admin() or user_id = auth.uid());
