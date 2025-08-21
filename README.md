# Glintly Shop

A modern, cross-platform e-commerce mobile app built with Flutter and Supabase.

## Features

### Customer Features
- **User Authentication**: Sign up, sign in, and password reset
- **Product Catalog**: Browse products with search and category filtering
- **Product Details**: View detailed product information with images
- **Shopping Cart**: Add, remove, and manage items in cart
- **Checkout**: Complete orders with shipping information
- **Order History**: View past orders and their status
- **User Profile**: Manage account settings and view order history

### Admin Features
- **Admin Dashboard**: Overview of store statistics and management options
- **Product Management**: Add, edit, and delete products
- **Order Management**: View and update order status
- **Responsive Design**: Works on mobile, tablet, and web

## Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL + Authentication + Real-time)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **UI**: Material Design 3 with custom theme
- **Image Caching**: cached_network_image
- **Form Validation**: Custom validators

## Architecture

The app follows a clean architecture pattern with:

- **Models**: Data models for User, Product, Cart, Order
- **Services**: API services for authentication, products, cart, orders
- **Providers**: State management with Riverpod
- **Screens**: UI screens organized by feature
- **Widgets**: Reusable UI components
- **Utils**: Utilities, constants, and validators

## Project Structure

```
lib/
├── config/           # App configuration (theme, Supabase)
├── models/           # Data models
├── services/         # API services
├── providers/        # State management
├── screens/          # UI screens
│   ├── auth/         # Authentication screens
│   ├── home/         # Home screen
│   ├── product/      # Product screens
│   ├── cart/         # Cart screen
│   ├── checkout/     # Checkout screen
│   ├── orders/       # Orders screen
│   ├── profile/      # Profile screen
│   └── admin/        # Admin screens
├── widgets/          # Reusable widgets
│   ├── common/       # Common widgets
│   ├── auth/         # Auth-specific widgets
│   ├── product/      # Product widgets
│   └── cart/         # Cart widgets
├── utils/            # Utilities and constants
└── main.dart         # App entry point
```

## Setup Instructions

### Prerequisites

1. Flutter SDK (>=3.10.0)
2. Dart SDK (>=3.0.0)
3. Supabase account

### Supabase Setup

1. Create a new Supabase project
2. Set up the following tables in your Supabase database:

#### Users/Profiles Table
```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  is_admin BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (id)
);
```

#### Products Table
```sql
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT,
  category TEXT NOT NULL,
  stock INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Cart Items Table
```sql
CREATE TABLE cart_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);
```

#### Orders Table
```sql
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  total_amount DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  shipping_address TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Order Items Table
```sql
CREATE TABLE order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

3. Set up Row Level Security (RLS) policies for each table
4. Get your Supabase URL and anon key

### Flutter Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Supabase:
   - Open `lib/config/supabase_config.dart`
   - Replace `YOUR_SUPABASE_URL` with your Supabase project URL
   - Replace `YOUR_SUPABASE_ANON_KEY` with your Supabase anon key

4. Run the app:
   ```bash
   # For mobile
   flutter run
   
   # For web
   flutter run -d chrome
   ```

## Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Features in Detail

### Authentication
- Email/password authentication via Supabase
- User profiles with full name and avatar support
- Admin role management
- Secure session management

### Product Management
- Product CRUD operations (admin only)
- Image support with fallback placeholders
- Category-based filtering
- Search functionality
- Stock management
- Active/inactive product status

### Shopping Cart
- Add/remove items
- Quantity management
- Real-time total calculation
- Persistent cart across sessions
- Clear cart functionality

### Order Processing
- Checkout with shipping information
- Order creation and management
- Order status tracking (pending, confirmed, shipped, delivered, cancelled)
- Order history for users
- Admin order management

### Responsive Design
- Mobile-first design
- Tablet and desktop support
- Adaptive layouts
- Cross-platform compatibility

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support or questions, please open an issue in the GitHub repository.