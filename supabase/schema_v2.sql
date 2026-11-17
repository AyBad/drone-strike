-- Drone Strike Field — V2.0.8 : alliances réelles (chef, demandes, historique), puissance et présence des joueurs
-- À exécuter une fois dans Supabase : SQL Editor > New query > coller > Run (après schema.sql).

alter table public.players add column if not exists power integer not null default 0;

create table if not exists public.alliances (
  id text primary key check (char_length(id) <= 16),
  name text not null check (char_length(name) between 3 and 18),
  tag text not null unique check (char_length(tag) between 3 and 4),
  ic text not null default 'shield' check (char_length(ic) <= 12),
  c text not null default '#4fd8ff' check (char_length(c) <= 9),
  leader uuid references public.players(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.ally_requests (
  ally text not null references public.alliances(id) on delete cascade,
  player uuid not null references public.players(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (ally, player)
);

create table if not exists public.ally_events (
  id bigint generated always as identity primary key,
  ally text not null check (char_length(ally) <= 16),
  nick text check (char_length(nick) <= 16),
  kind text not null check (kind in ('create', 'join', 'leave', 'kick', 'lead')),
  by_nick text check (by_nick is null or char_length(by_nick) <= 16),
  created_at timestamptz not null default now()
);
create index if not exists ally_events_ally on public.ally_events (ally, id desc);

alter table public.alliances enable row level security;
alter table public.ally_requests enable row level security;
alter table public.ally_events enable row level security;

drop policy if exists a_read on public.alliances;      create policy a_read on public.alliances for select to anon using (true);
drop policy if exists a_ins on public.alliances;       create policy a_ins on public.alliances for insert to anon with check (true);
drop policy if exists a_upd on public.alliances;       create policy a_upd on public.alliances for update to anon using (true) with check (true);
drop policy if exists a_del on public.alliances;       create policy a_del on public.alliances for delete to anon using (true);
drop policy if exists q_read on public.ally_requests;  create policy q_read on public.ally_requests for select to anon using (true);
drop policy if exists q_ins on public.ally_requests;   create policy q_ins on public.ally_requests for insert to anon with check (true);
drop policy if exists q_del on public.ally_requests;   create policy q_del on public.ally_requests for delete to anon using (true);
drop policy if exists e_read on public.ally_events;    create policy e_read on public.ally_events for select to anon using (true);
drop policy if exists e_ins on public.ally_events;     create policy e_ins on public.ally_events for insert to anon with check (true);

grant select, insert, update, delete on public.alliances to anon;
grant select, insert, delete on public.ally_requests to anon;
grant select, insert on public.ally_events to anon;
grant select, insert, update on public.players to anon;
