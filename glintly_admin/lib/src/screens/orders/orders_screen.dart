import 'package:flutter/material.dart';
import 'package:glintly_ui/glintly_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future<List<dynamic>>? _future;

  @override
  void initState() {
    super.initState();
    _future = Supabase.instance.client.from('orders').select('id, total, created_at').order('created_at');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Orders',
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const EmptyState(icon: Icons.error_outline, title: 'Failed to load orders');
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const EmptyState(icon: Icons.receipt_long_outlined, title: 'No orders yet');
          }
          return ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final o = orders[index] as Map<String, dynamic>;
              return ListTile(
                title: Text('Order #${o['id']}'),
                subtitle: Text(o['created_at']),
                trailing: Text('\u0024${(o['total'] as num).toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
    );
  }
}

