## Glintly Shop - Flutter + Supabase

This monorepo contains:

- `glintly_shop`: Cross-platform mobile app (Android/iOS/Web) for shopping
- `glintly_admin`: Flutter web admin dashboard (product CRUD, orders list)
- `packages/glintly_ui`: Shared UI components and modern light theme
- `supabase/schema.sql`: Database schema and RLS policies

### Prerequisites

- Flutter 3.24.x
- Supabase project URL and anon key

### Setup

1. Copy environment file:
   - Copy `.env.example` content into `glintly_shop/.env` and `glintly_admin/.env`
   - Set `SUPABASE_URL` and `SUPABASE_ANON_KEY`

2. Apply Supabase schema (from repo root):
   - Open Supabase SQL editor and run `supabase/schema.sql` contents

3. Get packages:
   - `flutter pub get` in `glintly_shop/` and `glintly_admin/`

### Run

- Shop app:
  - `cd glintly_shop`
  - `flutter run -d chrome` (web) or a connected device

- Admin app (web):
  - `cd glintly_admin`
  - `flutter run -d chrome`

### Notes

- Routing: `go_router`
- State: `Riverpod`
- Auth: Email/password via Supabase
- Orders: Creates `orders` and `order_items` rows during checkout

# Yashwanth-vijay