import 'package:flutter/material.dart';
import 'package:glintly_ui/glintly_ui.dart';
import 'package:go_router/go_router.dart';
import '../../services/product_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Glintly Shop',
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () => context.go('/cart'),
        )
      ],
      body: FutureBuilder(
        future: ProductService.instance.fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Failed to load products',
              message: 'Please try again later',
            );
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No products',
              message: 'Please check back soon',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return ProductCard(
                title: p.title,
                subtitle: p.description ?? '',
                price: p.price,
                imageUrl: p.imageUrl,
                onTap: () => context.go('/product/${p.id}')
              );
            },
          );
        },
      ),
    );
  }
}

