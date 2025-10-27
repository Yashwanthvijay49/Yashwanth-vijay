import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glintly_ui/glintly_ui.dart';
import 'package:go_router/go_router.dart';
import '../../state/cart_state.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    return AppScaffold(
      title: 'Cart',
      body: cart.items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              action: PrimaryButton(
                label: 'Browse products',
                icon: Icons.storefront,
                onPressed: () => context.go('/home'),
              ),
            )
          : ListView.separated(
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return ListTile(
                  leading: item.product.imageUrl != null
                      ? Image.network(item.product.imageUrl!, width: 56, height: 56, fit: BoxFit.cover)
                      : const Icon(Icons.inventory_2_outlined, size: 40),
                  title: Text(item.product.title),
                  subtitle: Text('\$${item.product.price.toStringAsFixed(2)}'),
                  trailing: QuantityStepper(
                    value: item.quantity,
                    onIncrement: () => cartNotifier.setQuantity(item.product, item.quantity + 1),
                    onDecrement: () => cartNotifier.setQuantity(item.product, item.quantity - 1),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Total: \$${cart.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  PrimaryButton(
                    label: 'Checkout',
                    icon: Icons.payment,
                    onPressed: () => context.go('/checkout'),
                  )
                ],
              ),
            ),
    );
  }
}

