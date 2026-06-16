-- ============================================================================
-- GMG SPORTS — Test Seed Data
-- Run in the Supabase SQL Editor (requires superuser / service role).
-- All test records use fixed UUIDs → ON CONFLICT DO NOTHING makes most
-- inserts idempotent. order_status_history rows accumulate on re-run
-- (harmless for testing, just clears the table before re-seeding if needed).
-- ============================================================================

-- ============================================================================
-- EXTRA COLLECTIONS (6 total)
-- ============================================================================
insert into public.collections (id, title, title_ar, description, image_url, sort_order) values
  ('55555555-5555-5555-5555-555555555555', 'Yoga & Fitness', 'يوغا ولياقة',  'Mats, bands & fitness accessories', 'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0', 5),
  ('66666666-6666-6666-6666-666666666666', 'Team Kits',      'أطقم الفريق', 'Jerseys, shorts & full kits',       'https://images.unsplash.com/photo-1551958219-acbc630e2914', 6)
on conflict (id) do nothing;

-- ============================================================================
-- EXTRA PRODUCTS (12 total after this)
-- ============================================================================
insert into public.products (id, name, name_ar, description, price, compare_at_price, images, stock, is_featured, is_active) values
  ('a0000007-0000-0000-0000-000000000007', 'Football Jersey',      'قميص كرة قدم',         'Lightweight performance jersey for match day.',    650,  850,  array['https://images.unsplash.com/photo-1551958219-acbc630e2914'], 80,  true,  true),
  ('a0000008-0000-0000-0000-000000000008', 'Yoga Mat Pro',         'حصيرة يوغا برو',       'Non-slip 6 mm thick yoga mat.',                   320,  420,  array['https://images.unsplash.com/photo-1599901860904-17e6ed7083a0'], 150, false, true),
  ('a0000009-0000-0000-0000-000000000009', 'Resistance Bands Set', 'طقم أشرطة مقاومة',    'Set of 5 resistance bands, light to heavy.',      280,  null, array['https://images.unsplash.com/photo-1598289431512-b97b0917affc'], 200, false, true),
  ('a0000010-0000-0000-0000-000000000010', 'Football Boots',       'حذاء كرة قدم',         'Firm-ground football boots, great traction.',     1800, 2200, array['https://images.unsplash.com/photo-1511886929837-354d827aae26'], 55,  true,  true),
  ('a0000011-0000-0000-0000-000000000011', 'Sports Socks 3-Pack',  'جوارب رياضية 3 أزواج', 'Cushioned ankle socks, multi-sport.',             150,  null, array['https://images.unsplash.com/photo-1586350977771-b3b0abd50c82'], 500, false, true),
  ('a0000012-0000-0000-0000-000000000012', 'Goalkeeper Gloves',    'قفازات حارس مرمى',    'Grip palms, wrist strap, all conditions.',        420,  550,  array['https://images.unsplash.com/photo-1614632537190-23e4146777db'], 40,  false, true)
on conflict (id) do nothing;

-- ============================================================================
-- PRODUCT → COLLECTION LINKS  (new products only)
-- ============================================================================
insert into public.product_collections (product_id, collection_id) values
  ('a0000007-0000-0000-0000-000000000007', '33333333-3333-3333-3333-333333333333'),  -- Jersey      → Football
  ('a0000007-0000-0000-0000-000000000007', '66666666-6666-6666-6666-666666666666'),  -- Jersey      → Team Kits
  ('a0000008-0000-0000-0000-000000000008', '55555555-5555-5555-5555-555555555555'),  -- Yoga Mat    → Yoga & Fitness
  ('a0000009-0000-0000-0000-000000000009', '55555555-5555-5555-5555-555555555555'),  -- Bands       → Yoga & Fitness
  ('a0000009-0000-0000-0000-000000000009', '11111111-1111-1111-1111-111111111111'),  -- Bands       → Training
  ('a0000010-0000-0000-0000-000000000010', '33333333-3333-3333-3333-333333333333'),  -- Boots       → Football
  ('a0000011-0000-0000-0000-000000000011', '11111111-1111-1111-1111-111111111111'),  -- Socks       → Training
  ('a0000011-0000-0000-0000-000000000011', '44444444-4444-4444-4444-444444444444'),  -- Socks       → Accessories
  ('a0000012-0000-0000-0000-000000000012', '33333333-3333-3333-3333-333333333333')   -- GK Gloves  → Football
on conflict do nothing;

-- ============================================================================
-- VARIANTS  (new products + previously un-variated existing ones)
-- ============================================================================
insert into public.product_variants (product_id, name, name_ar, price, stock, sort_order) values
  -- Compression Shorts (a0000004) — no variants in original seed
  ('a0000004-0000-0000-0000-000000000004', 'Size S',       'S',  null, 20,  1),
  ('a0000004-0000-0000-0000-000000000004', 'Size M',       'M',  null, 40,  2),
  ('a0000004-0000-0000-0000-000000000004', 'Size L',       'L',  null, 20,  3),
  ('a0000004-0000-0000-0000-000000000004', 'Size XL',      'XL', null, 10,  4),
  -- Football Jersey
  ('a0000007-0000-0000-0000-000000000007', 'Size S',       'S',  null, 15,  1),
  ('a0000007-0000-0000-0000-000000000007', 'Size M',       'M',  null, 30,  2),
  ('a0000007-0000-0000-0000-000000000007', 'Size L',       'L',  null, 25,  3),
  ('a0000007-0000-0000-0000-000000000007', 'Size XL',      'XL', null, 10,  4),
  -- Football Boots
  ('a0000010-0000-0000-0000-000000000010', 'EU 40',        null, null, 10,  1),
  ('a0000010-0000-0000-0000-000000000010', 'EU 41',        null, null, 15,  2),
  ('a0000010-0000-0000-0000-000000000010', 'EU 42',        null, null, 20,  3),
  ('a0000010-0000-0000-0000-000000000010', 'EU 43',        null, null, 10,  4),
  -- Goalkeeper Gloves
  ('a0000012-0000-0000-0000-000000000012', 'Size 8',       null, null, 10,  1),
  ('a0000012-0000-0000-0000-000000000012', 'Size 9',       null, null, 20,  2),
  ('a0000012-0000-0000-0000-000000000012', 'Size 10',      null, null, 10,  3),
  -- Sports Socks
  ('a0000011-0000-0000-0000-000000000011', 'S/M (36-40)',  null, null, 200, 1),
  ('a0000011-0000-0000-0000-000000000011', 'L/XL (41-46)',  null, null, 300, 2)
on conflict do nothing;

-- ============================================================================
-- EXTRA BANNERS  (4 total after this)
-- ============================================================================
insert into public.banners (image_url, title, link_type, link_id, sort_order) values
  ('https://images.unsplash.com/photo-1614632537190-23e4146777db', 'Football Season 2025', 'collection', '33333333-3333-3333-3333-333333333333', 3),
  ('https://images.unsplash.com/photo-1599901860904-17e6ed7083a0', 'Yoga & Wellness',      'collection', '55555555-5555-5555-5555-555555555555', 4)
on conflict do nothing;

-- ============================================================================
-- TEST AUTH USERS  (password for both: Test@1234)
-- Inserted directly into auth.users — only works in the Supabase SQL Editor
-- (which runs as postgres superuser) or via service role.
-- The handle_new_user trigger will create profiles automatically.
-- ============================================================================
insert into auth.users (
  id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_user_meta_data, raw_app_meta_data
) values
  (
    'aaaaaaaa-0000-0000-0000-000000000001',
    'authenticated', 'authenticated',
    'ahmed@test.com',
    crypt('Test@1234', gen_salt('bf')),
    now(), now() - interval '30 days', now(),
    '{"name": "Ahmed Hassan", "phone": "01012345678"}'::jsonb,
    '{"provider": "email", "providers": ["email"]}'::jsonb
  ),
  (
    'aaaaaaaa-0000-0000-0000-000000000002',
    'authenticated', 'authenticated',
    'sara@test.com',
    crypt('Test@1234', gen_salt('bf')),
    now(), now() - interval '20 days', now(),
    '{"name": "Sara Mohamed", "phone": "01098765432"}'::jsonb,
    '{"provider": "email", "providers": ["email"]}'::jsonb
  )
on conflict (id) do nothing;

-- Fallback in case trigger didn't fire (idempotent)
insert into public.profiles (id, email, name, phone, is_admin) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'ahmed@test.com', 'Ahmed Hassan', '01012345678', false),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'sara@test.com',  'Sara Mohamed', '01098765432', false)
on conflict (id) do nothing;

-- ============================================================================
-- ADDRESSES
-- ============================================================================
insert into public.addresses (id, user_id, label, full_name, phone, city, area, street, building, apartment, is_default) values
  ('c0000001-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'Home', 'Ahmed Hassan', '01012345678', 'Cairo', 'Nasr City', 'Abbas El-Akkad St', '15', 'Apt 3',   true),
  ('c0000002-0000-0000-0000-000000000002', 'aaaaaaaa-0000-0000-0000-000000000001', 'Work', 'Ahmed Hassan', '01012345678', 'Cairo', 'Maadi',     'Road 9',           '22', 'Floor 5', false),
  ('c0000003-0000-0000-0000-000000000003', 'aaaaaaaa-0000-0000-0000-000000000002', 'Home', 'Sara Mohamed', '01098765432', 'Giza',  'Dokki',     'Tahrir St',        '7',  'Apt 12',  true),
  ('c0000004-0000-0000-0000-000000000004', 'aaaaaaaa-0000-0000-0000-000000000002', 'Gym',  'Sara Mohamed', '01098765432', 'Cairo', 'Zamalek',   'Hassan Sabry St',  '3',  null,      false)
on conflict (id) do nothing;

-- ============================================================================
-- ORDERS  (one per status: pending ×2, confirmed, processing,
--           out_for_delivery, delivered ×2, cancelled)
--
-- Free delivery threshold: 1500 EGP  |  Delivery fee: 50 EGP
--
-- The trg_log_order_status trigger auto-logs the INSERT status into
-- order_status_history. We manually insert EARLIER statuses with past
-- timestamps to simulate a realistic timeline.
-- ============================================================================

-- ── 1. pending  (Ahmed, COD) ─────────────────────────────────────────────────
insert into public.orders (id, user_id, status, subtotal, delivery_fee, total,
  payment_method, delivery_date, recipient_name, recipient_phone, address_text, notes)
values (
  'b0000001-0000-0000-0000-000000000001',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'pending', 980.00, 50.00, 1030.00, 'cod', current_date + 3,
  'Ahmed Hassan', '01012345678',
  'Cairo, Nasr City, Abbas El-Akkad St, Bldg 15, Apt 3',
  'Please call before delivery'
) on conflict (id) do nothing;

insert into public.order_items (id, order_id, product_id, name, variant_name, unit_price, quantity, subtotal) values
  ('d0001001-0000-0000-0000-000000000001', 'b0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000001', 'GMG Pro Training Tee', 'Size M',      450.00, 1, 450.00),
  ('d0001002-0000-0000-0000-000000000001', 'b0000001-0000-0000-0000-000000000001', 'a0000004-0000-0000-0000-000000000004', 'Compression Shorts',   'Size M',      380.00, 1, 380.00),
  ('d0001003-0000-0000-0000-000000000001', 'b0000001-0000-0000-0000-000000000001', 'a0000011-0000-0000-0000-000000000011', 'Sports Socks 3-Pack',  'S/M (36-40)', 150.00, 1, 150.00)
on conflict (id) do nothing;
-- Trigger logs 'pending' automatically on order insert.

-- ── 2. pending  large cart (Sara, InstaPay — free delivery) ──────────────────
insert into public.orders (id, user_id, status, subtotal, delivery_fee, total,
  payment_method, delivery_date, recipient_name, recipient_phone, address_text)
values (
  'b0000002-0000-0000-0000-000000000002',
  'aaaaaaaa-0000-0000-0000-000000000002',
  'pending', 2480.00, 0.00, 2480.00, 'instapay', current_date + 4,
  'Sara Mohamed', '01098765432',
  'Cairo, Zamalek, Hassan Sabry St, Bldg 3'
) on conflict (id) do nothing;

insert into public.order_items (id, order_id, product_id, name, variant_name, unit_price, quantity, subtotal) values
  ('d0002001-0000-0000-0000-000000000001', 'b0000002-0000-0000-0000-000000000002', 'a0000002-0000-0000-0000-000000000002', 'Velocity Running Shoes', 'EU 41', 2200.00, 1, 2200.00),
  ('d0002002-0000-0000-0000-000000000001', 'b0000002-0000-0000-0000-000000000002', 'a0000009-0000-0000-0000-000000000009', 'Resistance Bands Set',   null,     280.00, 1,  280.00)
on conflict (id) do nothing;

-- ── 3. confirmed  (Sara, InstaPay) ────────────────────────────────────────────
insert into public.orders (id, user_id, status, subtotal, delivery_fee, total,
  payment_method, delivery_date, recipient_name, recipient_phone, address_text)
values (
  'b0000003-0000-0000-0000-000000000003',
  'aaaaaaaa-0000-0000-0000-000000000002',
  'confirmed', 320.00, 50.00, 370.00, 'instapay', current_date + 2,
  'Sara Mohamed', '01098765432',
  'Giza, Dokki, Tahrir St, Bldg 7, Apt 12'
) on conflict (id) do nothing;

insert into public.order_items (id, order_id, product_id, name, unit_price, quantity, subtotal) values
  ('d0003001-0000-0000-0000-000000000001', 'b0000003-0000-0000-0000-000000000003', 'a0000008-0000-0000-0000-000000000008', 'Yoga Mat Pro', 320.00, 1, 320.00)
on conflict (id) do nothing;

-- History: pending → (trigger logs confirmed)
insert into public.order_status_history (order_id, status, created_at)
  select 'b0000003-0000-0000-0000-000000000003', 'pending', now() - interval '3 hours'
  where not exists (
    select 1 from public.order_status_history
    where order_id = 'b0000003-0000-0000-0000-000000000003' and status = 'pending'
  );

-- ── 4. processing  (Ahmed, COD — free delivery above 1500 EGP) ───────────────
insert into public.orders (id, user_id, status, subtotal, delivery_fee, total,
  payment_method, delivery_date, recipient_name, recipient_phone, address_text)
values (
  'b0000004-0000-0000-0000-000000000004',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'processing', 2200.00, 0.00, 2200.00, 'cod', current_date + 1,
  'Ahmed Hassan', '01012345678',
  'Cairo, Nasr City, Abbas El-Akkad St, Bldg 15, Apt 3'
) on conflict (id) do nothing;

insert into public.order_items (id, order_id, product_id, name, variant_name, unit_price, quantity, subtotal) values
  ('d0004001-0000-0000-0000-000000000001', 'b0000004-0000-0000-0000-000000000004', 'a0000002-0000-0000-0000-000000000002', 'Velocity Running Shoes', 'EU 42', 2200.00, 1, 2200.00)
on conflict (id) do nothing;

insert into public.order_status_history (order_id, status, created_at)
  select order_id, status, ts from (values
    ('b0000004-0000-0000-0000-000000000004'::uuid, 'pending',   now() - interval '1 day'),
    ('b0000004-0000-0000-0000-000000000004'::uuid, 'confirmed', now() - interval '20 hours')
  ) as v(order_id, status, ts)
  where not exists (
    select 1 from public.order_status_history h
    where h.order_id = v.order_id and h.status = v.status
  );

-- ── 5. out_for_delivery  (Sara, COD) ─────────────────────────────────────────
insert into public.orders (id, user_id, status, subtotal, delivery_fee, total,
  payment_method, delivery_date, recipient_name, recipient_phone, address_text)
values (
  'b0000005-0000-0000-0000-000000000005',
  'aaaaaaaa-0000-0000-0000-000000000002',
  'out_for_delivery', 1400.00, 50.00, 1450.00, 'cod', current_date,
  'Sara Mohamed', '01098765432',
  'Giza, Dokki, Tahrir St, Bldg 7, Apt 12'
) on conflict (id) do nothing;

insert into public.order_items (id, order_id, product_id, name, variant_name, unit_price, quantity, subtotal) values
  ('d0005001-0000-0000-0000-000000000001', 'b0000005-0000-0000-0000-000000000005', 'a0000007-0000-0000-0000-000000000007', 'Football Jersey', 'Size M', 650.00, 1,  650.00),
  ('d0005002-0000-0000-0000-000000000001', 'b0000005-0000-0000-0000-000000000005', 'a0000003-0000-0000-0000-000000000003', 'Match Football',  null,     750.00, 1,  750.00)
on conflict (id) do nothing;

insert into public.order_status_history (order_id, status, created_at)
  select order_id, status, ts from (values
    ('b0000005-0000-0000-0000-000000000005'::uuid, 'pending',    now() - interval '2 days'),
    ('b0000005-0000-0000-0000-000000000005'::uuid, 'confirmed',  now() - interval '1 day 20 hours'),
    ('b0000005-0000-0000-0000-000000000005'::uuid, 'processing', now() - interval '1 day')
  ) as v(order_id, status, ts)
  where not exists (
    select 1 from public.order_status_history h
    where h.order_id = v.order_id and h.status = v.status
  );

-- ── 6. delivered  (Ahmed, InstaPay) — full timeline ──────────────────────────
insert into public.orders (id, user_id, status, subtotal, delivery_fee, total,
  payment_method, delivery_date, recipient_name, recipient_phone, address_text)
values (
  'b0000006-0000-0000-0000-000000000006',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'delivered', 980.00, 50.00, 1030.00, 'instapay', current_date - 1,
  'Ahmed Hassan', '01012345678',
  'Cairo, Nasr City, Abbas El-Akkad St, Bldg 15, Apt 3'
) on conflict (id) do nothing;

insert into public.order_items (id, order_id, product_id, name, unit_price, quantity, subtotal) values
  ('d0006001-0000-0000-0000-000000000001', 'b0000006-0000-0000-0000-000000000006', 'a0000005-0000-0000-0000-000000000005', 'Sports Backpack 25L', 980.00, 1, 980.00)
on conflict (id) do nothing;

insert into public.order_status_history (order_id, status, note, created_at)
  select order_id, status, note, ts from (values
    ('b0000006-0000-0000-0000-000000000006'::uuid, 'pending',          null,                          now() - interval '5 days'),
    ('b0000006-0000-0000-0000-000000000006'::uuid, 'confirmed',        'Payment verified',            now() - interval '4 days 20 hours'),
    ('b0000006-0000-0000-0000-000000000006'::uuid, 'processing',       null,                          now() - interval '4 days'),
    ('b0000006-0000-0000-0000-000000000006'::uuid, 'out_for_delivery', 'Driver: Omar — 01099887766',  now() - interval '1 day 6 hours')
  ) as v(order_id, status, note, ts)
  where not exists (
    select 1 from public.order_status_history h
    where h.order_id = v.order_id and h.status = v.status
  );

-- ── 7. delivered  (Sara, COD — free delivery) ────────────────────────────────
insert into public.orders (id, user_id, status, subtotal, delivery_fee, total,
  payment_method, delivery_date, recipient_name, recipient_phone, address_text)
values (
  'b0000007-0000-0000-0000-000000000007',
  'aaaaaaaa-0000-0000-0000-000000000002',
  'delivered', 1800.00, 0.00, 1800.00, 'cod', current_date - 3,
  'Sara Mohamed', '01098765432',
  'Giza, Dokki, Tahrir St, Bldg 7, Apt 12'
) on conflict (id) do nothing;

insert into public.order_items (id, order_id, product_id, name, variant_name, unit_price, quantity, subtotal) values
  ('d0007001-0000-0000-0000-000000000001', 'b0000007-0000-0000-0000-000000000007', 'a0000010-0000-0000-0000-000000000010', 'Football Boots', 'EU 42', 1800.00, 1, 1800.00)
on conflict (id) do nothing;

insert into public.order_status_history (order_id, status, created_at)
  select order_id, status, ts from (values
    ('b0000007-0000-0000-0000-000000000007'::uuid, 'pending',          now() - interval '7 days'),
    ('b0000007-0000-0000-0000-000000000007'::uuid, 'confirmed',        now() - interval '6 days 22 hours'),
    ('b0000007-0000-0000-0000-000000000007'::uuid, 'processing',       now() - interval '6 days'),
    ('b0000007-0000-0000-0000-000000000007'::uuid, 'out_for_delivery', now() - interval '3 days 8 hours')
  ) as v(order_id, status, ts)
  where not exists (
    select 1 from public.order_status_history h
    where h.order_id = v.order_id and h.status = v.status
  );

-- ── 8. cancelled  (Ahmed, COD) ───────────────────────────────────────────────
insert into public.orders (id, user_id, status, subtotal, delivery_fee, total,
  payment_method, delivery_date, recipient_name, recipient_phone, address_text, notes)
values (
  'b0000008-0000-0000-0000-000000000008',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'cancelled', 750.00, 50.00, 800.00, 'cod', null,
  'Ahmed Hassan', '01012345678',
  'Cairo, Maadi, Road 9, Bldg 22, Floor 5',
  'Changed my mind'
) on conflict (id) do nothing;

insert into public.order_items (id, order_id, product_id, name, unit_price, quantity, subtotal) values
  ('d0008001-0000-0000-0000-000000000001', 'b0000008-0000-0000-0000-000000000008', 'a0000003-0000-0000-0000-000000000003', 'Match Football', 750.00, 1, 750.00)
on conflict (id) do nothing;

insert into public.order_status_history (order_id, status, note, created_at)
  select order_id, status, note, ts from (values
    ('b0000008-0000-0000-0000-000000000008'::uuid, 'pending', null, now() - interval '3 days')
  ) as v(order_id, status, note, ts)
  where not exists (
    select 1 from public.order_status_history h
    where h.order_id = v.order_id and h.status = v.status
  );
-- Trigger logs 'cancelled' automatically on insert.

-- ============================================================================
-- ADMIN ACCOUNT
-- ============================================================================
insert into auth.users (
  id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_user_meta_data, raw_app_meta_data
) values (
  'ffffffff-0000-0000-0000-000000000001',
  'authenticated', 'authenticated',
  'admin@gmgsports.com',
  crypt('Admin@123', gen_salt('bf')),
  now(), now(), now(),
  '{"name": "GMG Admin"}'::jsonb,
  '{"provider": "email", "providers": ["email"]}'::jsonb
) on conflict (id) do nothing;

insert into public.profiles (id, email, name, is_admin) values
  ('ffffffff-0000-0000-0000-000000000001', 'admin@gmgsports.com', 'GMG Admin', true)
on conflict (id) do update set is_admin = true;

-- ============================================================================
-- REGULAR USER ACCOUNT
-- ============================================================================
insert into auth.users (
  id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_user_meta_data, raw_app_meta_data
) values (
  'ffffffff-0000-0000-0000-000000000002',
  'authenticated', 'authenticated',
  'customer@gmgsports.com',
  crypt('User@123', gen_salt('bf')),
  now(), now(), now(),
  '{"name": "Test Customer", "phone": "01011112222"}'::jsonb,
  '{"provider": "email", "providers": ["email"]}'::jsonb
) on conflict (id) do nothing;

insert into public.profiles (id, email, name, phone, is_admin) values
  ('ffffffff-0000-0000-0000-000000000002', 'customer@gmgsports.com', 'Test Customer', '01011112222', false)
on conflict (id) do nothing;

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- Admin account
--   Email:    admin@gmgsports.com
--   Password: Admin@123
--
-- Regular user account
--   Email:    customer@gmgsports.com
--   Password: User@123
--
-- Test accounts  (password: Test@1234)
--   ahmed@test.com  — orders: pending, processing, delivered, cancelled
--   sara@test.com   — orders: pending ×2, confirmed, out_for_delivery, delivered
-- ============================================================================
