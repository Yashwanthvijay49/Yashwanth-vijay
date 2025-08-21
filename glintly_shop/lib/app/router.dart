import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/sign_in_page.dart';
import '../features/auth/sign_up_page.dart';
import '../features/auth/auth_gate.dart';
import '../features/shop/product_list_page.dart';
import '../features/shop/product_detail_page.dart';
import '../features/cart/cart_page.dart';
import '../features/checkout/checkout_page.dart';
import '../admin/admin_products_page.dart';
import '../admin/admin_product_form_page.dart';
import 'navigation_config.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final initialLocation = ref.watch(initialLocationProvider);
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) => const ProductListPage(),
        routes: [
          GoRoute(
            path: 'product/:id',
            name: 'product',
            builder: (context, state) => ProductDetailPage(productId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'cart',
            name: 'cart',
            builder: (context, state) => const AuthGate(child: CartPage()),
          ),
          GoRoute(
            path: 'checkout',
            name: 'checkout',
            builder: (context, state) => const AuthGate(child: CheckoutPage()),
          ),
        ],
      ),
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'sign-up',
        builder: (context, state) => const SignUpPage(),
      ),
      if (kIsWeb)
        GoRoute(
          path: '/admin',
          name: 'admin',
          builder: (context, state) => const AdminProductsPage(),
          routes: [
            GoRoute(
              path: 'product/new',
              name: 'admin-product-new',
              builder: (context, state) => const AdminProductFormPage(),
            ),
            GoRoute(
              path: 'product/:id',
              name: 'admin-product-edit',
              builder: (context, state) => AdminProductFormPage(productId: state.pathParameters['id']!),
            ),
          ],
        ),
    ],
  );
});