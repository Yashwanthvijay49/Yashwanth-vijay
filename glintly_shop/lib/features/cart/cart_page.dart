import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'cart_controller.dart';
import '../../utils/price_formatter.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartControllerProvider);
    final total = ref.read(cartControllerProvider.notifier).totalCents();
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(height: 0),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _CartRow(item: item);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(formatPrice(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => context.go('/checkout'),
                          child: const Text('Checkout'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}

class _CartRow extends ConsumerWidget {
  const _CartRow({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(cartControllerProvider.notifier);
    return ListTile(
      title: Text(item.product.title),
      subtitle: Text(formatPrice(item.lineTotalCents)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: () => controller.decrementProduct(item.product.id), icon: const Icon(Icons.remove_circle_outline)),
          Text(item.quantity.toString()),
          IconButton(onPressed: () => controller.addProduct(item.product), icon: const Icon(Icons.add_circle_outline)),
          IconButton(onPressed: () => controller.removeProduct(item.product.id), icon: const Icon(Icons.delete_outline)),
        ],
      ),
    );
  }
}