-- ============================================================
-- WORKSHEET 9 - SQL Schema untuk Supabase
-- ============================================================

-- ==========================================
-- PRAKTIK 3 — Tabel profiles (Role Pengguna)
-- ==========================================
create table if not exists public.profiles (
  id    uuid primary key references auth.users(id) on delete cascade,
  email text,
  name  text,
  role  text not null default 'seeker'
        check (role in ('seeker', 'owner', 'admin'))
);

alter table public.profiles enable row level security;

-- user hanya boleh membaca profile miliknya sendiri.
-- Tidak ada policy UPDATE, sehingga user tidak dapat mengubah role sendiri.
create policy "profiles_select_own"
  on public.profiles for select to authenticated
  using (auth.uid() = id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', ''),
    case
      when new.raw_user_meta_data->>'role' in ('seeker', 'owner')
        then new.raw_user_meta_data->>'role'
      else 'seeker'
    end
  );
  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- ==========================================
-- PRAKTIK 5 — Tabel kos dengan RLS
-- ==========================================
create table if not exists public.kos (
  id         uuid primary key default gen_random_uuid(),
  owner_id   uuid not null default auth.uid()
             references auth.users(id) on delete cascade,
  name       text not null,
  address    text,
  price      integer,
  created_at timestamptz not null default now()
);

alter table public.kos enable row level security;

-- 1. SELECT: semua user yang sudah login boleh membaca
create policy "kos_select_authenticated"
  on public.kos for select to authenticated
  using (true);

-- 2. INSERT: owner_id harus sama dengan user yang login,
--    dan role harus owner / admin
create policy "kos_insert_owner"
  on public.kos for insert to authenticated
  with check (
    auth.uid() = owner_id
    and exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role in ('owner', 'admin')
    )
  );

-- 3. UPDATE: hanya pemilik data
create policy "kos_update_own"
  on public.kos for update to authenticated
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

-- 4. DELETE: hanya pemilik data
create policy "kos_delete_own"
  on public.kos for delete to authenticated
  using (auth.uid() = owner_id);

-- Policy untuk Admin
create or replace function public.is_admin()
returns boolean
language sql stable
security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

create policy "kos_admin_all"
  on public.kos for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());


-- ==========================================
-- PRAKTIK 9 — Tabel device_tokens (FCM)
-- ==========================================
create table if not exists public.device_tokens (
  token      text primary key,
  user_id    uuid not null default auth.uid()
             references auth.users(id) on delete cascade,
  platform   text,
  updated_at timestamptz not null default now()
);

alter table public.device_tokens enable row level security;

create policy "tokens_select_own" on public.device_tokens
  for select to authenticated using (auth.uid() = user_id);

create policy "tokens_insert_own" on public.device_tokens
  for insert to authenticated with check (auth.uid() = user_id);

create policy "tokens_update_own" on public.device_tokens
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "tokens_delete_own" on public.device_tokens
  for delete to authenticated using (auth.uid() = user_id);
