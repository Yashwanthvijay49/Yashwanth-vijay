import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/shop/product_model.dart';
import '../features/shop/product_repository.dart';

final adminProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repo = buildProductRepository();
  return repo.listProducts();
});

class AdminProductsPage extends ConsumerWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(adminProductsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Products'),
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.store_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/admin/product/new'),
        child: const Icon(Icons.add),
      ),
      body: asyncProducts.when(
        data: (products) => ListView.separated(
          itemCount: products.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (context, index) {
            final p = products[index];
            return ListTile(
              title: Text(p.title),
              subtitle: Text('ID: ${p.id}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.go('/admin/product/${p.id}'),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}