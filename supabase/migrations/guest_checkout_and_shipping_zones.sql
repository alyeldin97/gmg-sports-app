-- ============================================================================
-- Migration: guest checkout support + shipping zones table
-- Run this in the Supabase SQL Editor.
-- ============================================================================

-- 1. Add new columns to orders (idempotent)
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS client_ref     uuid,
  ADD COLUMN IF NOT EXISTS guest_email    text,
  ADD COLUMN IF NOT EXISTS governorate_id uuid,
  ADD COLUMN IF NOT EXISTS governorate_name text;

-- 2. Create governorates / shipping-zones table
CREATE TABLE IF NOT EXISTS public.governorates (
  id            uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          text NOT NULL,
  name_ar       text,
  shipping_cost numeric(10,2) NOT NULL DEFAULT 0,
  delivery_days int  NOT NULL DEFAULT 3,
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- RLS for governorates
ALTER TABLE public.governorates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "governorates public read" ON public.governorates;
CREATE POLICY "governorates public read" ON public.governorates
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "governorates admin write" ON public.governorates;
CREATE POLICY "governorates admin write" ON public.governorates
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- 3. Fix orders INSERT policy to allow guest (unauthenticated) orders
DROP POLICY IF EXISTS "orders owner insert" ON public.orders;
CREATE POLICY "orders owner insert" ON public.orders
  FOR INSERT WITH CHECK (
    (auth.uid() IS NOT NULL AND auth.uid() = user_id) OR
    (auth.uid() IS NULL   AND user_id IS NULL)
  );

-- 4. Fix order_items INSERT policy to allow guest orders
DROP POLICY IF EXISTS "order_items insert" ON public.order_items;
CREATE POLICY "order_items insert" ON public.order_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = order_id AND (
        (auth.uid() IS NOT NULL AND o.user_id = auth.uid()) OR
        (auth.uid() IS NULL     AND o.user_id IS NULL)
      )
    )
  );

-- 5. Fix orders SELECT policy: guests can read their own order for up to 1 hour
--    after placement (covers the immediate post-checkout read).
DROP POLICY IF EXISTS "orders owner read" ON public.orders;
CREATE POLICY "orders owner read" ON public.orders
  FOR SELECT USING (
    auth.uid() = user_id
    OR public.is_admin()
    OR (user_id IS NULL AND created_at > now() - interval '1 hour')
  );

-- 6. Fix order_items SELECT to match
DROP POLICY IF EXISTS "order_items read" ON public.order_items;
CREATE POLICY "order_items read" ON public.order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = order_id AND (
        o.user_id = auth.uid()
        OR public.is_admin()
        OR (o.user_id IS NULL AND o.created_at > now() - interval '1 hour')
      )
    )
  );

-- 7. Fix order_status_history SELECT to match
DROP POLICY IF EXISTS "order_history read" ON public.order_status_history;
CREATE POLICY "order_history read" ON public.order_status_history
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = order_id AND (
        o.user_id = auth.uid()
        OR public.is_admin()
        OR (o.user_id IS NULL AND o.created_at > now() - interval '1 hour')
      )
    )
  );
