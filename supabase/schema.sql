-- Drone Strike Field — V2 : schéma du jeu en ligne (chat, profils, réactions, signalements)
-- À exécuter une seule fois dans Supabase : SQL Editor > New query > coller > Run.
-- Phase de test : accès par la clé publique (rôle anon), sans compte. L'authentification viendra plus tard.

create table if not exists public.players (
  id uuid primary key,
  nick text not null check (char_length(nick) between 1 and 16),
  av text not null default 'd0' check (char_length(av) <= 4),
  photo text check (photo is null or char_length(photo) <= 60000),
  bio text check (bio is null or char_length(bio) <= 140),
  country text check (country is null or char_length(country) <= 2),
  ally text check (ally is null or char_length(ally) <= 16),
  lang text check (lang is null or char_length(lang) <= 5),
  updated_at timestamptz not null default now()
);

create table if not exists public.messages (
  id bigint generated always as identity primary key,
  channel text not null check (char_length(channel) <= 90),
  sender uuid not null references public.players(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 160),
  lang text check (lang is null or char_length(lang) <= 5),
  created_at timestamptz not null default now()
);
create index if not exists messages_channel_id on public.messages (channel, id desc);

create table if not exists public.msg_reactions (
  msg_id bigint not null references public.messages(id) on delete cascade,
  player uuid not null references public.players(id) on delete cascade,
  kind text not null check (kind in ('like', 'dis')),
  primary key (msg_id, player)
);

create table if not exists public.player_likes (
  liker uuid not null references public.players(id) on delete cascade,
  target uuid not null references public.players(id) on delete cascade,
  primary key (liker, target),
  check (liker <> target)
);

create table if not exists public.reports (
  id bigint generated always as identity primary key,
  msg_id bigint references public.messages(id) on delete set null,
  reporter uuid not null,
  body text,
  created_at timestamptz not null default now()
);

alter table public.players enable row level security;
alter table public.messages enable row level security;
alter table public.msg_reactions enable row level security;
alter table public.player_likes enable row level security;
alter table public.reports enable row level security;

drop policy if exists p_read on public.players;       create policy p_read on public.players for select to anon using (true);
drop policy if exists p_ins on public.players;        create policy p_ins on public.players for insert to anon with check (true);
drop policy if exists p_upd on public.players;        create policy p_upd on public.players for update to anon using (true) with check (true);
drop policy if exists m_read on public.messages;      create policy m_read on public.messages for select to anon using (true);
drop policy if exists m_ins on public.messages;       create policy m_ins on public.messages for insert to anon with check (true);
drop policy if exists r_read on public.msg_reactions; create policy r_read on public.msg_reactions for select to anon using (true);
drop policy if exists r_ins on public.msg_reactions;  create policy r_ins on public.msg_reactions for insert to anon with check (true);
drop policy if exists r_upd on public.msg_reactions;  create policy r_upd on public.msg_reactions for update to anon using (true) with check (true);
drop policy if exists r_del on public.msg_reactions;  create policy r_del on public.msg_reactions for delete to anon using (true);
drop policy if exists l_read on public.player_likes;  create policy l_read on public.player_likes for select to anon using (true);
drop policy if exists l_ins on public.player_likes;   create policy l_ins on public.player_likes for insert to anon with check (true);
drop policy if exists l_del on public.player_likes;   create policy l_del on public.player_likes for delete to anon using (true);
drop policy if exists s_ins on public.reports;        create policy s_ins on public.reports for insert to anon with check (true);

grant usage on schema public to anon;
grant select, insert, update on public.players to anon;
grant select, insert on public.messages to anon;
grant select, insert, update, delete on public.msg_reactions to anon;
grant select, insert, delete on public.player_likes to anon;
grant insert on public.reports to anon;
