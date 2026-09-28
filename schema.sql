-- Supabase SQL Editor で一度実行。Authentication > Providers > Anonymous sign-ins を有効化する。
create table if not exists public.test_profiles (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid(),
  display_name text not null check (char_length(display_name) between 1 and 20),
  created_at timestamptz not null default now()
);
create index if not exists test_profiles_owner_idx on public.test_profiles(owner_id);
alter table public.test_profiles enable row level security;
revoke all on public.test_profiles from anon;
grant select, insert on public.test_profiles to authenticated;
drop policy if exists test_profiles_select on public.test_profiles;
create policy test_profiles_select on public.test_profiles for select to authenticated using (owner_id = (select auth.uid()));
drop policy if exists test_profiles_insert on public.test_profiles;
create policy test_profiles_insert on public.test_profiles for insert to authenticated with check (owner_id = (select auth.uid()));
create or replace function public.limit_test_profiles() returns trigger
language plpgsql security invoker set search_path = '' as $$
begin
  if new.owner_id is distinct from auth.uid() then
    raise exception '登録者が一致しません';
  end if;
  -- 同じ匿名ユーザーによる同時登録も直列化する。
  perform pg_advisory_xact_lock(hashtextextended(new.owner_id::text, 0));
  if (select count(*) from public.test_profiles where owner_id = new.owner_id) >= 3 then
    raise exception 'この端末では3人まで登録できます';
  end if;
  return new;
end $$;
drop trigger if exists limit_test_profiles_trigger on public.test_profiles;
create trigger limit_test_profiles_trigger before insert on public.test_profiles
for each row execute function public.limit_test_profiles();
