-- Supabase schema for Glintly Shop
create table if not exists products (
  id bigint generated always as identity primary key,
  title text not null,
  description text,
  price numeric(10,2) not null default 0,
  image_url text,
  created_at timestamp with time zone default now()
);

create table if not exists orders (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id),
  total numeric(10,2) not null default 0,
  created_at timestamp with time zone default now()
);

create table if not exists order_items (
  id bigint generated always as identity primary key,
  order_id bigint references orders(id) on delete cascade,
  product_id bigint references products(id),
  quantity int not null default 1,
  unit_price numeric(10,2) not null default 0
);

-- RLS
alter table products enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;

-- Products readable to all, writable to authenticated users (admin role can be enforced via edge function or policy)
create policy if not exists "Products are readable to all" on products for select using (true);
create policy if not exists "Products insert for authenticated" on products for insert with check (auth.uid() is not null);
create policy if not exists "Products update for authenticated" on products for update using (auth.uid() is not null);
create policy if not exists "Products delete for authenticated" on products for delete using (auth.uid() is not null);

-- Orders: users can see and create their own orders
create policy if not exists "Orders select own" on orders for select using (user_id = auth.uid());
create policy if not exists "Orders insert own" on orders for insert with check (user_id = auth.uid());

-- Order items: accessible via parent order ownership
create policy if not exists "Order items by order ownership" on order_items for select using (
  exists (select 1 from orders o where o.id = order_items.order_id and o.user_id = auth.uid())
);
create policy if not exists "Order items insert by owner" on order_items for insert with check (
  exists (select 1 from orders o where o.id = order_items.order_id and o.user_id = auth.uid())
);

