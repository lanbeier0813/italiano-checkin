-- Italiano Check-in Supabase schema
-- Run this whole file in Supabase Dashboard -> SQL Editor -> New query -> Run.

create table if not exists app_users (
  username text primary key,
  password text not null,
  role text not null check (role in ('teacher', 'student')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists daily_tasks (
  task_date text primary key,
  homework text default '',
  dictation text default '',
  recite text default '',
  speaking text default '',
  updated_at timestamptz not null default now()
);

create table if not exists student_tasks (
  username text not null references app_users(username) on delete cascade,
  task_date text not null,
  homework text default '',
  dictation text default '',
  recite text default '',
  speaking text default '',
  updated_at timestamptz not null default now(),
  primary key (username, task_date)
);

create table if not exists checkins (
  username text not null references app_users(username) on delete cascade,
  checkin_date text not null,
  homework boolean not null default false,
  dictation boolean not null default false,
  recite boolean not null default false,
  speaking boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (username, checkin_date)
);

create table if not exists streaks (
  username text primary key references app_users(username) on delete cascade,
  streak integer not null default 0,
  flowers integer not null default 0,
  last_checkin_date text,
  updated_at timestamptz not null default now()
);

create table if not exists chat_messages (
  id text primary key,
  username text not null,
  role text not null check (role in ('teacher', 'student')),
  message text not null,
  created_at timestamptz not null
);

create table if not exists hidden_chat_messages (
  username text not null references app_users(username) on delete cascade,
  message_key text not null,
  hidden_at timestamptz not null default now(),
  primary key (username, message_key)
);

alter table app_users enable row level security;
alter table daily_tasks enable row level security;
alter table student_tasks enable row level security;
alter table checkins enable row level security;
alter table streaks enable row level security;
alter table chat_messages enable row level security;
alter table hidden_chat_messages enable row level security;

drop policy if exists "public app_users all" on app_users;
drop policy if exists "public daily_tasks all" on daily_tasks;
drop policy if exists "public student_tasks all" on student_tasks;
drop policy if exists "public checkins all" on checkins;
drop policy if exists "public streaks all" on streaks;
drop policy if exists "public chat_messages all" on chat_messages;
drop policy if exists "public hidden_chat_messages all" on hidden_chat_messages;

create policy "public app_users all" on app_users for all using (true) with check (true);
create policy "public daily_tasks all" on daily_tasks for all using (true) with check (true);
create policy "public student_tasks all" on student_tasks for all using (true) with check (true);
create policy "public checkins all" on checkins for all using (true) with check (true);
create policy "public streaks all" on streaks for all using (true) with check (true);
create policy "public chat_messages all" on chat_messages for all using (true) with check (true);
create policy "public hidden_chat_messages all" on hidden_chat_messages for all using (true) with check (true);

insert into app_users (username, password, role) values
  ('toni', '123456', 'teacher'),
  ('a1', 'a1888888', 'teacher')
on conflict (username) do update set
  password = excluded.password,
  role = excluded.role,
  updated_at = now();

insert into chat_messages (id, username, role, message, created_at) values
  ('2026-06-10T03:39:55.194Z|toni|teacher|ciao', 'toni', 'teacher', 'ciao', '2026-06-10T03:39:55.194Z'),
  ('2026-06-10T05:18:44.597Z|a|student|ciao', 'a', 'student', 'ciao', '2026-06-10T05:18:44.597Z'),
  ('2026-06-12T03:11:23.849Z|ceshi|student|ciao', 'ceshi', 'student', 'ciao', '2026-06-12T03:11:23.849Z'),
  ('mqae10fccohfcc', 'toni', 'teacher', 'hello', '2026-06-12T03:49:34.440Z')
on conflict (id) do update set
  username = excluded.username,
  role = excluded.role,
  message = excluded.message,
  created_at = excluded.created_at;

insert into hidden_chat_messages (username, message_key) values
  ('toni', '2026-06-12T03:11:23.849Z|ceshi|student|ciao'),
  ('toni', '2026-06-10T03:39:55.194Z|toni|teacher|ciao'),
  ('toni', '2026-06-10T05:18:44.597Z|a|student|ciao'),
  ('a1', '2026-06-10T03:39:55.194Z|toni|teacher|ciao'),
  ('a1', '2026-06-10T05:18:44.597Z|a|student|ciao')
on conflict (username, message_key) do nothing;
