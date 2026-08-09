-- =====================================================================
-- GoalsFORGold – Supabase Schema
-- Einmalig im Supabase SQL-Editor ausführen (Dashboard → SQL Editor →
-- neues Query → einfügen → Run).
-- =====================================================================

-- ---------- Tabellen ----------
create table if not exists teams (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'Mein Team',
  config jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists coach_emails (
  email text primary key
);

create table if not exists members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  team_id uuid not null references teams(id) on delete cascade,
  role text not null check (role in ('coach','athlet')),
  athlete_key text
);

create table if not exists athletes (
  team_id uuid not null references teams(id) on delete cascade,
  key text not null,
  email text,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (team_id, key)
);

-- ---------- Startdaten ----------
insert into teams (name) select 'Swiss-Ski'
  where not exists (select 1 from teams);

insert into coach_emails (email) values
  ('bjoern.bruhin@swiss-ski.ch'),
  ('silvano.stadler@swiss-ski.ch')
on conflict do nothing;

-- ---------- Hilfsfunktionen (security definer umgeht RLS-Rekursion) ----------
create or replace function public.is_coach()
returns boolean language sql stable security definer set search_path = public as
$$ select exists(select 1 from members where user_id = auth.uid() and role = 'coach') $$;

create or replace function public.my_athlete_key()
returns text language sql stable security definer set search_path = public as
$$ select athlete_key from members where user_id = auth.uid() limit 1 $$;

-- ---------- Automatische Verknüpfung neuer Konten ----------
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare t uuid; a record;
begin
  select id into t from teams limit 1;
  if exists (select 1 from coach_emails where lower(email) = lower(new.email)) then
    insert into members (user_id, team_id, role)
      values (new.id, t, 'coach')
      on conflict (user_id) do nothing;
  else
    select * into a from athletes where lower(email) = lower(new.email) limit 1;
    if found then
      insert into members (user_id, team_id, role, athlete_key)
        values (new.id, a.team_id, 'athlet', a.key)
        on conflict (user_id) do update set athlete_key = excluded.athlete_key;
    end if;
  end if;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Verknüpfung auch, wenn der Coach die Athletin ERST NACH deren Signup anlegt
create or replace function public.link_athlete_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare u uuid;
begin
  if new.email is not null then
    select id into u from auth.users where lower(email) = lower(new.email) limit 1;
    if found and not exists (select 1 from coach_emails where lower(email) = lower(new.email)) then
      insert into members (user_id, team_id, role, athlete_key)
        values (u, new.team_id, 'athlet', new.key)
        on conflict (user_id) do update set athlete_key = excluded.athlete_key;
    end if;
  end if;
  return new;
end $$;

drop trigger if exists on_athlete_upsert on athletes;
create trigger on_athlete_upsert
  after insert or update of email on athletes
  for each row execute function public.link_athlete_user();

-- ---------- Row Level Security ----------
alter table teams enable row level security;
alter table members enable row level security;
alter table athletes enable row level security;
alter table coach_emails enable row level security;

-- teams: alle Angemeldeten lesen (Config), nur Coaches ändern
drop policy if exists teams_select on teams;
create policy teams_select on teams for select to authenticated using (true);
drop policy if exists teams_update on teams;
create policy teams_update on teams for update to authenticated using (public.is_coach());

-- members: eigene Zeile lesen, Coaches lesen alle
drop policy if exists members_select on members;
create policy members_select on members for select to authenticated
  using (user_id = auth.uid() or public.is_coach());

-- athletes: Coaches alles; Athlet:innen lesen und ändern nur die eigene Zeile
drop policy if exists athletes_coach_all on athletes;
create policy athletes_coach_all on athletes for all to authenticated
  using (public.is_coach()) with check (public.is_coach());
drop policy if exists athletes_own_select on athletes;
create policy athletes_own_select on athletes for select to authenticated
  using (key = public.my_athlete_key());
drop policy if exists athletes_own_update on athletes;
create policy athletes_own_update on athletes for update to authenticated
  using (key = public.my_athlete_key()) with check (key = public.my_athlete_key());

-- coach_emails: kein Client-Zugriff (nur security-definer-Funktionen lesen sie)
