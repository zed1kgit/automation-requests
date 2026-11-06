-- Выполнить в Supabase: SQL Editor -> New query -> Run

create table if not exists public.requests (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title       text not null check (length(btrim(title)) between 1 and 150),
  description text not null check (length(btrim(description)) > 0),
  category    text not null check (category in ('Бот','Интеграция','Отчёт','Другое')),
  status      text not null default 'Новая' check (status in ('Новая','В работе','Завершена')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists requests_user_created_idx on public.requests (user_id, created_at desc);

-- updated_at и защита от смены владельца
create or replace function public.requests_before_update() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  new.user_id := old.user_id;
  return new;
end $$;

drop trigger if exists requests_before_update on public.requests;
create trigger requests_before_update before update on public.requests
  for each row execute function public.requests_before_update();

-- Row Level Security: доступ ограничен на уровне базы
alter table public.requests enable row level security;

drop policy if exists "own select" on public.requests;
drop policy if exists "own insert" on public.requests;
drop policy if exists "own update" on public.requests;
drop policy if exists "own delete" on public.requests;

create policy "own select" on public.requests for select to authenticated using (auth.uid() = user_id);
create policy "own insert" on public.requests for insert to authenticated with check (auth.uid() = user_id);
create policy "own update" on public.requests for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own delete" on public.requests for delete to authenticated using (auth.uid() = user_id);

-- Анонимные пользователи не имеют доступа к таблице
revoke all on public.requests from anon;
grant select, insert, update, delete on public.requests to authenticated;
