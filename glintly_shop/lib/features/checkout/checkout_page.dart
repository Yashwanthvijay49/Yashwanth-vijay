import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../cart/cart_controller.dart';
import '../../utils/price_formatter.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  Future<void> _placeOrder(BuildContext context, WidgetRef ref) async {
    final items = ref.read(cartControllerProvider);
    final total = ref.read(cartControllerProvider.notifier).totalCents();
    try {
      final supabase = Supabase.instance.client;
      final data = {
        'items': items
            .map((e) => {
                  'product_id': e.product.id,
                  'title': e.product.title,
                  'quantity': e.quantity,
                  'price_cents': e.product.priceCents,
                })
            .toList(),
        'total_cents': total,
      };
      await supabase.from('orders').insert(data);
      if (context.mounted) {
        ref.read(cartControllerProvider.notifier).clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed!')));
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartControllerProvider);
    final total = ref.read(cartControllerProvider.notifier).totalCents();
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map((e) => ListTile(
                  dense: true,
                  title: Text('${e.quantity} × ${e.product.title}'),
                  trailing: Text(formatPrice(e.lineTotalCents)),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(formatPrice(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: items.isEmpty ? null : () => _placeOrder(context, ref),
                child: const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}