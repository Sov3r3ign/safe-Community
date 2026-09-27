-- SafeZone first vertical slice: authentication profiles + incident reporting.
-- Run this in the Supabase SQL Editor on a NEW/EMPTY SafeZone project.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  name text not null,
  phone text,
  role text not null default 'resident' check (role in ('resident', 'patrol_officer', 'admin')),
  verification_status text not null default 'not_required'
    check (verification_status in ('not_required', 'pending', 'approved', 'rejected')),
  created_at timestamptz not null default now()
);

create table if not exists public.incidents (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  type text not null,
  severity text not null check (severity in ('Low', 'Medium', 'High', 'Critical')),
  status text not null default 'Pending'
    check (status in ('Pending', 'Verified', 'Investigating', 'Resolved', 'Rejected')),
  location text not null,
  lat double precision not null,
  lng double precision not null,
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  reporter_name text not null,
  has_media boolean not null default false,
  media_url text,
  created_at timestamptz not null default now()
);

create index if not exists incidents_created_at_idx on public.incidents(created_at desc);
create index if not exists incidents_reporter_id_idx on public.incidents(reporter_id);

-- Create a public app profile from trusted Auth signup lifecycle.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, email, name, phone, role, verification_status)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'name', 'SafeZone User'),
    new.raw_user_meta_data ->> 'phone',
    coalesce(new.raw_user_meta_data ->> 'role', 'resident'),
    case
      when coalesce(new.raw_user_meta_data ->> 'role', 'resident') = 'patrol_officer' then 'pending'
      else 'not_required'
    end
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.incidents enable row level security;

-- A user can only read their own full profile. This avoids exposing phone/email
-- to every community member just to render an incident feed.
create policy "users can read own profile"
on public.profiles for select
to authenticated
using ((select auth.uid()) = id);

create policy "users can update own profile"
on public.profiles for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

-- Everyone signed in can see community incidents, but can only create reports
-- attached to their own authenticated user id.
create policy "authenticated users can read incidents"
on public.incidents for select
to authenticated
using (true);

create policy "users can create own incidents"
on public.incidents for insert
to authenticated
with check ((select auth.uid()) = reporter_id);

-- Least privilege: app users may edit only non-privileged profile fields.
grant select on table public.profiles to authenticated;
grant update (name, phone) on table public.profiles to authenticated;
grant select, insert on table public.incidents to authenticated;
