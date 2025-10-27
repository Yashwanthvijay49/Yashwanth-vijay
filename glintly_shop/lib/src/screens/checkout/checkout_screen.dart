import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glintly_ui/glintly_ui.dart';
import '../../state/cart_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool loading = false;
  String? error;
  String? successMessage;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    return AppScaffold(
      title: 'Checkout',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            if (successMessage != null)
              Text(successMessage!, style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 8),
            Text('Order summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final i = cart.items[index];
                  return ListTile(
                    title: Text(i.product.title),
                    trailing: Text('x${i.quantity}  \$${(i.product.price * i.quantity).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text('Total: \$${cart.total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                PrimaryButton(
                  label: 'Place order',
                  loading: loading,
                  onPressed: cart.items.isEmpty ? null : _placeOrder,
                  icon: Icons.check_circle_outline,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    final cartNotifier = ref.read(cartProvider.notifier);
    final cart = ref.read(cartProvider);
    setState(() {
      loading = true;
      error = null;
      successMessage = null;
    });
    try {
      final client = Supabase.instance.client;
      final orderRes = await client.from('orders').insert({
        'total': cart.total,
      }).select().single();
      final orderId = orderRes['id'];
      final items = cart.items
          .map((i) => {
                'order_id': orderId,
                'product_id': i.product.id,
                'quantity': i.quantity,
                'unit_price': i.product.price,
              })
          .toList();
      await client.from('order_items').insert(items);
      cartNotifier.clear();
      setState(() => successMessage = 'Order placed successfully!');
    } catch (e) {
      setState(() => error = 'Failed to place order');
    } finally {
      setState(() => loading = false);
    }
  }
}

