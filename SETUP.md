# GMG Sports — Setup Guide

Two Flutter apps backed by a shared Supabase project:

| App | Folder | Audience |
|---|---|---|
| Customer ecommerce app | `gmg/` | Shoppers (mobile + web) |
| Admin dashboard | `gmg_dashboard/` | Store admins (web/desktop) |

Brand: **GMG Sports** — amber/gold (`#FFC107`) on near-black, white surfaces.
Both apps support **English + Arabic (RTL)** and use the `logo.png` as their identity.

---

## 1. Create the Supabase project & schema

1. Create a project at [supabase.com](https://supabase.com).
2. Open **SQL Editor** and run the contents of [`supabase/schema.sql`](supabase/schema.sql).
   This creates all tables, row-level-security policies, triggers, and seed
   sports-gear data (collections, products, variants, banners).
3. **Create your admin user**: in the customer app (or Supabase Auth dashboard),
   sign up a user, then promote it:
   ```sql
   update public.profiles set is_admin = true where email = 'admin@gmgsports.com';
   ```
   Only `is_admin = true` profiles can log into the dashboard.

### Data model
`profiles` (with `is_admin`), `collections`, `products`, `product_variants`,
`product_collections`, `banners`, `addresses`, `app_settings`, `orders`,
`order_items`, `order_status_history` (drives the tracking timeline, written by
a trigger on every status change).

---

## 2. Configure credentials (currently DUMMY placeholders)

Replace the placeholder values in **both** apps with your project's URL and
anon/publishable key (Supabase → Project Settings → API):

- `gmg/lib/core/utils/configurations.dart`
- `gmg_dashboard/lib/core/utils/configurations.dart`

```dart
static const String supabaseUrl     = 'https://YOUR-REF.supabase.co';
static const String supabaseAnonKey = 'YOUR-ANON-KEY';
```

Both apps must point at the **same** project.

---

## 3. Run

```bash
# Customer app
cd gmg
flutter pub get
flutter run -d chrome        # or any device

# Admin dashboard (best on web/desktop — uses a side nav)
cd ../gmg_dashboard
flutter pub get
flutter run -d chrome
```

Localizations are generated automatically (`generate: true`); if needed run
`flutter gen-l10n`.

---

## Features

### Customer app (`gmg`)
- Email/password **auth**, **guest mode** ("continue as guest")
- **Home**: banner carousel, collections rail, featured products
- **Collections** & **product** browsing, product details with **variant picker**
- **Cart** (local, works for guests), quantity editing
- **Checkout**: address selection, **delivery date**, payment method
  (**Cash on delivery** / **InstaPay on delivery**), order notes, summary
- **Address management** (add / edit / default)
- **Order tracking** with a status timeline; order history
- Profile, language toggle (EN/AR)

### Admin dashboard (`gmg_dashboard`)
- **Admin-only login** (rejects non-admin accounts)
- **Overview** with order/revenue/product stats
- **Products** CRUD (incl. variants, multi-collection assignment, featured/active)
- **Collections** CRUD
- **Banners** CRUD (with collection/product deep-link targets)
- **Orders**: view all, drill into details, **update status** (drives customer tracking)
- **Settings**: delivery fee, free-delivery threshold, InstaPay handle

---

## Architecture
Feature-first clean architecture (Cubit → Repository → DataSource → Supabase),
matching the conventions in [`code_structure.md`](code_structure.md). Each
feature: `data/{model,remote,repo}` + `presentation/{cubits,screens,widgets}`.
A hand-rolled `DependencyInjector` singleton wires everything; cubits are
provided via `MultiBlocProvider`.
