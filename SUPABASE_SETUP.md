# Supabase Database Setup Guide

This guide will help you set up the Supabase database for the Glintly Shop app.

## 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click "New Project"
3. Fill in your project details
4. Wait for the project to be created

## 2. Database Schema Setup

Run the following SQL commands in the Supabase SQL Editor:

### Create Tables

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table (extends auth.users)
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

-- Products table
CREATE TABLE products (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
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

-- Cart items table
CREATE TABLE cart_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Orders table
CREATE TABLE orders (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  total_amount DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  shipping_address TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order items table
CREATE TABLE order_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Create Functions and Triggers

```sql
-- Function to handle user profile creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Set up Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" ON profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = true
    )
  );

-- Products policies
CREATE POLICY "Anyone can view active products" ON products
  FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage products" ON products
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = true
    )
  );

-- Cart items policies
CREATE POLICY "Users can manage own cart items" ON cart_items
  FOR ALL USING (auth.uid() = user_id);

-- Orders policies
CREATE POLICY "Users can view own orders" ON orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own orders" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all orders" ON orders
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = true
    )
  );

CREATE POLICY "Admins can update all orders" ON orders
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = true
    )
  );

-- Order items policies
CREATE POLICY "Users can view own order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create order items for own orders" ON order_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can view all order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = true
    )
  );
```

### Insert Sample Data

```sql
-- Insert sample products
INSERT INTO products (name, description, price, category, stock, image_url) VALUES
('iPhone 14 Pro', 'Latest Apple smartphone with advanced camera system', 999.99, 'Electronics', 50, 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=300'),
('MacBook Air M2', 'Lightweight laptop with M2 chip for ultimate performance', 1199.99, 'Electronics', 30, 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=300'),
('Nike Air Max 270', 'Comfortable running shoes with Air Max technology', 149.99, 'Clothing', 100, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300'),
('The Great Gatsby', 'Classic American novel by F. Scott Fitzgerald', 12.99, 'Books', 200, 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300'),
('Garden Tool Set', 'Complete set of essential gardening tools', 89.99, 'Home & Garden', 75, 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=300'),
('Yoga Mat', 'Non-slip exercise mat for yoga and fitness', 29.99, 'Sports', 150, 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=300'),
('Skincare Set', 'Complete skincare routine with natural ingredients', 79.99, 'Beauty', 80, 'https://images.unsplash.com/photo-1556228578-dd6e4aaac9d5?w=300'),
('LEGO Architecture Set', 'Build famous landmarks with LEGO bricks', 199.99, 'Toys', 40, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300'),
('Organic Coffee Beans', 'Premium organic coffee beans from Colombia', 24.99, 'Food', 300, 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=300'),
('Wireless Headphones', 'Noise-cancelling wireless headphones', 299.99, 'Electronics', 60, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300');

-- Create an admin user (you'll need to sign up first, then update this)
-- Replace 'your-user-id-here' with your actual user ID after signing up
-- UPDATE profiles SET is_admin = true WHERE id = 'your-user-id-here';
```

## 3. Configure App

1. Go to Settings > API in your Supabase dashboard
2. Copy your Project URL and anon public key
3. Update `lib/config/supabase_config.dart` with your credentials:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  // ... rest of the code
}
```

## 4. Create Admin User

1. Sign up for an account in your app
2. Go to Authentication > Users in your Supabase dashboard
3. Copy your user ID
4. Run this SQL command in the SQL Editor:

```sql
UPDATE profiles SET is_admin = true WHERE id = 'your-user-id-here';
```

## 5. Test the Setup

1. Run your Flutter app
2. Sign up/sign in
3. Browse products
4. Add items to cart
5. Complete checkout
6. Access admin dashboard (if you're an admin)

Your Supabase database is now ready for the Glintly Shop app!