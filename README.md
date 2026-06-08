# GMG Sports — Customer App

Flutter ecommerce app for the **GMG Sports** gear brand, backed by Supabase.
Brand identity: amber/gold (`#FFC107`) on near-black. Supports **English + Arabic (RTL)**.

> Companion admin dashboard: **gmg-sports-dashboard**.

## Features
- Email/password **auth** + **guest mode**
- **Home** — banner carousel, collections rail, featured products
- **Collections** & **products** browsing, product details with **variant picker**
- **Cart** (local, guest-friendly)
- **Checkout** — address selection, **delivery-date picker**, **Cash on delivery / InstaPay on delivery**, order notes
- **Address management**
- **Order tracking** with a status timeline + order history
- Profile, language toggle

## Stack
`flutter_bloc` (Cubit) · `supabase_flutter` · `flutter_screenutil` · `google_fonts` ·
feature-first clean architecture (Cubit → Repository → DataSource → Supabase).

## Getting started
1. Create a Supabase project and run [`supabase/schema.sql`](supabase/schema.sql).
2. Put your project URL + anon key in `lib/core/utils/configurations.dart`
   (currently **dummy placeholders**).
3. `flutter pub get && flutter run`

Full instructions in [SETUP.md](SETUP.md).
