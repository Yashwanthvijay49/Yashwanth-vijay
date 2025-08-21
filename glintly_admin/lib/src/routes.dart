import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/admin_sign_in_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/products/product_form_screen.dart';
import 'screens/orders/orders_screen.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthed = session != null;
      final loggingIn = state.matchedLocation.startsWith('/sign-in');
      if (!isAuthed && !loggingIn) return '/sign-in';
      if (isAuthed && loggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/sign-in', builder: (_, __) => const AdminSignInScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/products/new', builder: (_, __) => const ProductFormScreen()),
      GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
    ],
  );
});

