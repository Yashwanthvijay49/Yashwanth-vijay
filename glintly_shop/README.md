# Glintly Shop

Cross-platform Flutter shop app with Supabase backend and a Flutter Web admin dashboard.

## Features
- User signup/login (Supabase Auth)
- Product listing and details (Supabase PostgREST)
- Cart and checkout (creates `orders` in Supabase)
- Admin dashboard (web) with product CRUD
- Modern Material 3 light theme, responsive layouts

## Requirements
- Flutter 3.10+ (tested on 3.35)
- A Supabase project with tables:
  - `products` (id uuid/text/int, title text, description text, price_cents int, image_url text)
  - `orders` (id uuid, items jsonb, total_cents int)
- Supabase anon key and URL

## Config
Provide Supabase credentials at build/run time via `--dart-define`:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Example:
```bash
flutter run -t lib/main.dart \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

For web admin (navigate to `/admin`) run the admin entrypoint:
```bash
flutter run -t lib/main_admin.dart -d chrome \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```
Then ensure the browser URL is `/admin`.

## Run targets
- Mobile app: `lib/main.dart`
- Admin web: `lib/main_admin.dart`

## Notes
- Authentication is required for cart/checkout; browsing products is public.
- Replace placeholders and extend models/validation as needed.
- For production, add RLS policies in Supabase to secure tables.
