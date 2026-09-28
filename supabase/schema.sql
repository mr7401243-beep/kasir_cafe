-- =====================================================================
-- FEY COFFEE - Skema database Supabase
-- Cara pakai: Supabase Dashboard -> SQL Editor -> New query -> paste -> Run
-- Aman dijalankan ulang (idempotent) selama belum ada data penting.
-- =====================================================================

-- ---------- TABEL ----------
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  full_name  text,
  role       text not null default 'kasir' check (role in ('admin', 'kasir')),
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id         bigint generated always as identity primary key,
  name       text not null,
  price      numeric(12,0) not null check (price >= 0),
  category   text not null,
  icon       text not null default '☕',
  is_active  boolean not null default true,
  created_at timestamptz not null default now()
);

create sequence if not exists public.invoice_seq;

create table if not exists public.transactions (
  id             uuid primary key default gen_random_uuid(),
  invoice_no     text not null unique,
  user_id        uuid not null default auth.uid() references auth.users(id),
  total          numeric(12,0) not null check (total >= 0),
  payment        numeric(12,0) not null check (payment >= 0),
  change_amount  numeric(12,0) not null check (change_amount >= 0),
  payment_method text not null check (payment_method in ('Cash', 'QRIS')),
  created_at     timestamptz not null default now()
);

create table if not exists public.transaction_items (
  id             bigint generated always as identity primary key,
  transaction_id uuid not null references public.transactions(id) on delete cascade,
  product_id     bigint references public.products(id) on delete set null,
  product_name   text not null,                 -- snapshot nama saat transaksi
  price          numeric(12,0) not null,        -- snapshot harga saat transaksi
  quantity       int not null check (quantity > 0),
  subtotal       numeric(12,0) not null
);

create index if not exists idx_transactions_created_at on public.transactions (created_at desc);
create index if not exists idx_transactions_user_id    on public.transactions (user_id);
create index if not exists idx_items_transaction_id    on public.transaction_items (transaction_id);

-- ---------- HELPER ----------
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  );
$$;

-- Otomatis buat profil saat user baru dibuat di Authentication
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Untuk user yang SUDAH ada sebelum skema ini dijalankan
insert into public.profiles (id, full_name)
select id, split_part(email, '@', 1) from auth.users
on conflict (id) do nothing;

-- ---------- ROW LEVEL SECURITY ----------
alter table public.profiles          enable row level security;
alter table public.products          enable row level security;
alter table public.transactions      enable row level security;
alter table public.transaction_items enable row level security;

drop policy if exists "profiles_select" on public.profiles;
create policy "profiles_select" on public.profiles
  for select to authenticated
  using (id = auth.uid() or public.is_admin());

drop policy if exists "products_select" on public.products;
create policy "products_select" on public.products
  for select to authenticated using (true);

drop policy if exists "products_admin_write" on public.products;
create policy "products_admin_write" on public.products
  for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- Transaksi hanya dibuat lewat fungsi create_transaction (tidak ada policy insert)
drop policy if exists "transactions_select" on public.transactions;
create policy "transactions_select" on public.transactions
  for select to authenticated
  using (user_id = auth.uid() or public.is_admin());

drop policy if exists "items_select" on public.transaction_items;
create policy "items_select" on public.transaction_items
  for select to authenticated
  using (exists (select 1 from public.transactions t where t.id = transaction_id));

-- ---------- FUNGSI TRANSAKSI (atomik + total dihitung di server) ----------
-- p_items = [{"product_id": 1, "quantity": 2}, ...]
create or replace function public.create_transaction(
  p_items   jsonb,
  p_payment numeric,
  p_method  text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid     uuid := auth.uid();
  v_total   numeric := 0;
  v_payment numeric := p_payment;
  v_tx_id   uuid;
  v_invoice text;
  v_item    jsonb;
  v_prod    public.products%rowtype;
  v_qty     int;
begin
  if v_uid is null then
    raise exception 'Anda harus login terlebih dahulu';
  end if;
  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'Keranjang masih kosong';
  end if;
  if p_method not in ('Cash', 'QRIS') then
    raise exception 'Metode pembayaran tidak valid';
  end if;

  -- 1) hitung total dari harga di database (bukan dari aplikasi)
  for v_item in select * from jsonb_array_elements(p_items) loop
    v_qty := (v_item->>'quantity')::int;
    if v_qty is null or v_qty <= 0 then
      raise exception 'Jumlah produk tidak valid';
    end if;
    select * into v_prod
      from public.products
     where id = (v_item->>'product_id')::bigint and is_active;
    if not found then
      raise exception 'Produk tidak ditemukan atau sudah tidak aktif';
    end if;
    v_total := v_total + v_prod.price * v_qty;
  end loop;

  if p_method = 'QRIS' then
    v_payment := v_total;
  end if;
  if v_payment is null or v_payment < v_total then
    raise exception 'Uang pembayaran tidak mencukupi';
  end if;

  -- 2) simpan transaksi
  v_invoice := to_char(now() at time zone 'Asia/Jakarta', 'YYYYMMDD')
               || '-' || lpad(nextval('public.invoice_seq')::text, 5, '0');

  insert into public.transactions (invoice_no, user_id, total, payment, change_amount, payment_method)
  values (v_invoice, v_uid, v_total, v_payment, v_payment - v_total, p_method)
  returning id into v_tx_id;

  -- 3) simpan item
  for v_item in select * from jsonb_array_elements(p_items) loop
    v_qty := (v_item->>'quantity')::int;
    select * into v_prod from public.products where id = (v_item->>'product_id')::bigint;
    insert into public.transaction_items (transaction_id, product_id, product_name, price, quantity, subtotal)
    values (v_tx_id, v_prod.id, v_prod.name, v_prod.price, v_qty, v_prod.price * v_qty);
  end loop;

  return jsonb_build_object(
    'id', v_tx_id,
    'invoice_no', v_invoice,
    'total', v_total,
    'payment', v_payment,
    'change_amount', v_payment - v_total
  );
end;
$$;

revoke all on function public.create_transaction(jsonb, numeric, text) from public, anon;
grant execute on function public.create_transaction(jsonb, numeric, text) to authenticated;

-- ---------- DATA AWAL (menu) ----------
insert into public.products (name, price, category, icon)
select * from (values
  ('Espresso',     15000, 'Coffee',     '☕'),
  ('Americano',    18000, 'Coffee',     '☕'),
  ('Cappuccino',   25000, 'Coffee',     '🥛'),
  ('Latte',        25000, 'Coffee',     '☕'),
  ('Matcha Latte', 22000, 'Non Coffee', '🍵'),
  ('Chocolate',    22000, 'Non Coffee', '🍫'),
  ('Croissant',    18000, 'Food',       '🥐'),
  ('French Fries', 20000, 'Food',       '🍟')
) as v(name, price, category, icon)
where not exists (select 1 from public.products);

-- ---------- ADMIN PERTAMA ----------
-- Setelah membuat user di Authentication -> Users, jadikan admin dengan:
--   update public.profiles set role = 'admin'
--   where id = (select id from auth.users where email = 'emailanda@contoh.com');
