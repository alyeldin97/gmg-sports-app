-- Fix: log_order_status trigger now runs as SECURITY DEFINER so it can insert
-- into order_status_history without requiring the customer to have INSERT permission.
-- Run this once in the Supabase SQL Editor.

create or replace function public.log_order_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if (tg_op = 'INSERT') or (new.status is distinct from old.status) then
    insert into public.order_status_history (order_id, status)
    values (new.id, new.status);
  end if;
  return new;
end;
$$;
