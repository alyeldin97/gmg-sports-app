-- ============================================================================
-- GMG SPORTS — Supabase schema
-- Customer ecommerce app + Admin dashboard share this single database.
-- Run this in the Supabase SQL editor (or `supabase db push`).
-- ============================================================================

-- Required extensions ---------------------------------------------------------
create extension if not exists "uuid-ossp";

-- ============================================================================
-- PROFILES  (one row per auth user; `is_admin` gates the dashboard)
-- ============================================================================
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  email       text,
  name        text not null default '',
  phone       text,
  is_admin    boolean not null default false,
  created_at  timestamptz not null default now()
);

-- Helper: is the current user an admin? (SECURITY DEFINER avoids RLS recursion)
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select coalesce(
    (select p.is_admin from public.profiles p where p.id = auth.uid()),
    false
  );
$$;

-- Auto-create a profile row whenever a new auth user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, name, phone)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'name', split_part(new.email, '@', 1)),
    new.raw_user_meta_data ->> 'phone'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================================
-- COLLECTIONS
-- ============================================================================
create table if not exists public.collections (
  id          uuid primary key default uuid_generate_v4(),
  title       text not null,
  title_ar    text,
  description text,
  image_url   text,
  sort_order  int not null default 0,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

-- ============================================================================
-- PRODUCTS
-- ============================================================================
create table if not exists public.products (
  id               uuid primary key default uuid_generate_v4(),
  name             text not null,
  name_ar          text,
  description      text,
  description_ar   text,
  price            numeric(10,2) not null default 0,
  compare_at_price numeric(10,2),
  images           text[] not null default '{}',
  stock            int not null default 0,
  is_active        boolean not null default true,
  is_featured      boolean not null default false,
  created_at       timestamptz not null default now()
);

-- Product ↔ Collection (many-to-many)
create table if not exists public.product_collections (
  product_id    uuid references public.products (id) on delete cascade,
  collection_id uuid references public.collections (id) on delete cascade,
  primary key (product_id, collection_id)
);

-- Product variants (e.g. sizes / colors)
create table if not exists public.product_variants (
  id          uuid primary key default uuid_generate_v4(),
  product_id  uuid not null references public.products (id) on delete cascade,
  name        text not null,
  name_ar     text,
  price       numeric(10,2),
  stock       int not null default 0,
  sku         text,
  sort_order  int not null default 0,
  is_active   boolean not null default true
);

-- ============================================================================
-- BANNERS  (home carousel)
-- ============================================================================
create table if not exists public.banners (
  id          uuid primary key default uuid_generate_v4(),
  title       text,
  image_url   text not null,
  link_type   text not null default 'none',   -- none | collection | product
  link_id     uuid,
  sort_order  int not null default 0,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

-- ============================================================================
-- ADDRESSES
-- ============================================================================
create table if not exists public.addresses (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  label       text,                 -- Home / Work / ...
  full_name   text not null,
  phone       text not null,
  city        text not null,
  area        text,
  street      text not null,
  building    text,
  apartment   text,
  notes       text,
  is_default  boolean not null default false,
  created_at  timestamptz not null default now()
);

-- ============================================================================
-- APP SETTINGS (single row, id = 1)
-- ============================================================================
create table if not exists public.app_settings (
  id                      int primary key default 1,
  currency                text not null default 'EGP',
  delivery_fee            numeric(10,2) not null default 50,
  free_delivery_threshold numeric(10,2) not null default 1500,
  instapay_handle         text not null default 'gmgsports@instapay',
  updated_at              timestamptz not null default now(),
  constraint app_settings_singleton check (id = 1)
);

insert into public.app_settings (id) values (1) on conflict (id) do nothing;

-- ============================================================================
-- ORDERS
-- ============================================================================
create table if not exists public.orders (
  id             uuid primary key default uuid_generate_v4(),
  user_id        uuid references auth.users (id) on delete set null,
  status         text not null default 'pending',  -- pending|confirmed|processing|out_for_delivery|delivered|cancelled
  subtotal       numeric(10,2) not null default 0,
  delivery_fee   numeric(10,2) not null default 0,
  total          numeric(10,2) not null default 0,
  payment_method text not null default 'cod',      -- cod | instapay
  delivery_date  date,
  recipient_name text not null default '',
  recipient_phone text not null default '',
  address_text   text not null default '',
  notes          text,
  created_at     timestamptz not null default now()
);

create table if not exists public.order_items (
  id           uuid primary key default uuid_generate_v4(),
  order_id     uuid not null references public.orders (id) on delete cascade,
  product_id   uuid references public.products (id) on delete set null,
  variant_id   uuid references public.product_variants (id) on delete set null,
  name         text not null,
  variant_name text,
  unit_price   numeric(10,2) not null,
  quantity     int not null,
  subtotal     numeric(10,2) not null
);

create table if not exists public.order_status_history (
  id         uuid primary key default uuid_generate_v4(),
  order_id   uuid not null references public.orders (id) on delete cascade,
  status     text not null,
  note       text,
  created_at timestamptz not null default now()
);

-- Log an initial + every status change into history automatically.
create or replace function public.log_order_status()
returns trigger
language plpgsql
as $$
begin
  if (tg_op = 'INSERT') or (new.status is distinct from old.status) then
    insert into public.order_status_history (order_id, status)
    values (new.id, new.status);
  end if;
  return new;
end;
$$;

drop trigger if exists trg_log_order_status on public.orders;
create trigger trg_log_order_status
  after insert or update of status on public.orders
  for each row execute function public.log_order_status();

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
alter table public.profiles            enable row level security;
alter table public.collections         enable row level security;
alter table public.products            enable row level security;
alter table public.product_collections enable row level security;
alter table public.product_variants    enable row level security;
alter table public.banners             enable row level security;
alter table public.addresses           enable row level security;
alter table public.app_settings        enable row level security;
alter table public.orders              enable row level security;
alter table public.order_items         enable row level security;
alter table public.order_status_history enable row level security;

-- Profiles -------------------------------------------------------------------
create policy "profiles self read"   on public.profiles for select using (auth.uid() = id or public.is_admin());
create policy "profiles self insert" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles self update" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

-- Public catalog (anyone, incl. guests, can read; only admins write) ----------
do $$
declare t text;
begin
  foreach t in array array['collections','products','product_collections','product_variants','banners','app_settings']
  loop
    execute format('create policy "%1$s public read" on public.%1$s for select using (true);', t);
    execute format('create policy "%1$s admin write" on public.%1$s for all using (public.is_admin()) with check (public.is_admin());', t);
  end loop;
end $$;

-- Addresses ------------------------------------------------------------------
create policy "addresses owner" on public.addresses
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Orders ---------------------------------------------------------------------
create policy "orders owner read"  on public.orders for select using (auth.uid() = user_id or public.is_admin());
create policy "orders owner insert" on public.orders for insert with check (auth.uid() = user_id);
create policy "orders admin update" on public.orders for update using (public.is_admin()) with check (public.is_admin());

create policy "order_items read" on public.order_items for select
  using (exists (select 1 from public.orders o where o.id = order_id and (o.user_id = auth.uid() or public.is_admin())));
create policy "order_items insert" on public.order_items for insert
  with check (exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));

create policy "order_history read" on public.order_status_history for select
  using (exists (select 1 from public.orders o where o.id = order_id and (o.user_id = auth.uid() or public.is_admin())));

-- ============================================================================
-- SEED DATA — GMG Sports gear
-- ============================================================================
insert into public.collections (id, title, title_ar, description, image_url, sort_order) values
  ('11111111-1111-1111-1111-111111111111', 'Training',  'تدريب',   'Gear for every workout',        'https://images.unsplash.com/photo-1517836357463-d25dfeac3438', 1),
  ('22222222-2222-2222-2222-222222222222', 'Running',   'جري',     'Lightweight running essentials','https://images.unsplash.com/photo-1542291026-7eec264c27ff', 2),
  ('33333333-3333-3333-3333-333333333333', 'Football',  'كرة قدم', 'Boots, balls & kits',           'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d', 3),
  ('44444444-4444-4444-4444-444444444444', 'Accessories','إكسسوار','Bags, bottles & more',          'https://images.unsplash.com/photo-1556906781-9a412961c28c', 4)
on conflict (id) do nothing;

insert into public.products (id, name, name_ar, description, price, compare_at_price, images, stock, is_featured) values
  ('a0000001-0000-0000-0000-000000000001', 'GMG Pro Training Tee', 'تيشيرت تدريب برو', 'Breathable moisture-wicking training t-shirt.', 450, 600, array['https://images.unsplash.com/photo-1521572163474-6864f9cf17ab'], 120, true),
  ('a0000002-0000-0000-0000-000000000002', 'Velocity Running Shoes', 'حذاء جري فيلوسيتي', 'Responsive cushioning for long runs.', 2200, 2800, array['https://images.unsplash.com/photo-1542291026-7eec264c27ff'], 60, true),
  ('a0000003-0000-0000-0000-000000000003', 'Match Football', 'كرة قدم ماتش', 'FIFA-quality match ball, size 5.', 750, null, array['https://images.unsplash.com/photo-1614632537190-23e4146777db'], 200, true),
  ('a0000004-0000-0000-0000-000000000004', 'Compression Shorts', 'شورت ضاغط', 'Second-skin compression shorts.', 380, null, array['https://images.unsplash.com/photo-1517649763962-0c623066013b'], 90, false),
  ('a0000005-0000-0000-0000-000000000005', 'Sports Backpack 25L', 'شنطة رياضية 25 لتر', 'Durable gym & travel backpack.', 980, 1200, array['https://images.unsplash.com/photo-1553062407-98eeb64c6a62'], 45, true),
  ('a0000006-0000-0000-0000-000000000006', 'Insulated Water Bottle', 'زجاجة مياه حافظة', 'Keeps drinks cold for 24h.', 250, null, array['https://images.unsplash.com/photo-1602143407151-7111542de6e8'], 300, false)
on conflict (id) do nothing;

insert into public.product_collections (product_id, collection_id) values
  ('a0000001-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111'),
  ('a0000004-0000-0000-0000-000000000004', '11111111-1111-1111-1111-111111111111'),
  ('a0000002-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222'),
  ('a0000003-0000-0000-0000-000000000003', '33333333-3333-3333-3333-333333333333'),
  ('a0000005-0000-0000-0000-000000000005', '44444444-4444-4444-4444-444444444444'),
  ('a0000006-0000-0000-0000-000000000006', '44444444-4444-4444-4444-444444444444')
on conflict do nothing;

insert into public.product_variants (product_id, name, price, stock, sort_order) values
  ('a0000001-0000-0000-0000-000000000001', 'Size S', null, 30, 1),
  ('a0000001-0000-0000-0000-000000000001', 'Size M', null, 50, 2),
  ('a0000001-0000-0000-0000-000000000001', 'Size L', null, 40, 3),
  ('a0000002-0000-0000-0000-000000000002', 'EU 41', null, 15, 1),
  ('a0000002-0000-0000-0000-000000000002', 'EU 42', null, 20, 2),
  ('a0000002-0000-0000-0000-000000000002', 'EU 43', null, 25, 3)
on conflict do nothing;

insert into public.banners (image_url, title, link_type, link_id, sort_order) values
  ('https://images.unsplash.com/photo-1551698618-1dfe5d97d256', 'New Season Drop', 'collection', '22222222-2222-2222-2222-222222222222', 1),
  ('https://images.unsplash.com/photo-1461896836934-ffe607ba8211', 'Train Harder',    'collection', '11111111-1111-1111-1111-111111111111', 2)
on conflict do nothing;

-- ----------------------------------------------------------------------------
-- After creating your admin user via Supabase Auth, promote them:
--   update public.profiles set is_admin = true where email = 'admin@gmgsports.com';
-- ----------------------------------------------------------------------------
