import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../config/app_theme.dart';
import '../../utils/constants.dart';
import '../../models/order_model.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Load orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminOrderNotifierProvider.notifier).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(adminOrderNotifierProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Manage Orders',
        showBackButton: true,
        showCartIcon: false,
      ),
      body: orders.when(
        data: (orderList) {
          if (orderList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppConstants.paddingMD),
                  Text(
                    'No orders found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: AppConstants.paddingSM),
                  Text(
                    'Orders will appear here when customers place them',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(adminOrderNotifierProvider.notifier).loadOrders();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMD),
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                final order = orderList[index];
                return _AdminOrderCard(
                  order: order,
                  currencyFormat: currencyFormat,
                  onStatusChanged: (status) => _updateOrderStatus(order.id, status),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: AppConstants.paddingMD),
              Text(
                'Failed to load orders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.errorColor,
                    ),
              ),
              const SizedBox(height: AppConstants.paddingMD),
              ElevatedButton(
                onPressed: () {
                  ref.read(adminOrderNotifierProvider.notifier).loadOrders();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await ref.read(adminOrderNotifierProvider.notifier).updateOrderStatus(
            orderId: orderId,
            status: status,
          );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${status.name}'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order status: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;
  final NumberFormat currencyFormat;
  final Function(OrderStatus) onStatusChanged;

  const _AdminOrderCard({
    required this.order,
    required this.currencyFormat,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMD),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                _StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSM),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppConstants.paddingSM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.items.fold<int>(0, (sum, item) => sum + item.quantity)} items',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                currencyFormat.format(order.totalAmount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order items
                Text(
                  'Order Items',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingSM),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.paddingSM),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                            ),
                            child: const Icon(
                              Icons.shopping_bag,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMD),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Qty: ${item.quantity} × ${currencyFormat.format(item.product.price)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            currencyFormat.format(item.totalPrice),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    )),
                const Divider(),

                // Shipping address
                Text(
                  'Shipping Address',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingSM),
                Text(
                  order.shippingAddress,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppConstants.paddingMD),

                // Status update
                Text(
                  'Update Status',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingSM),
                Wrap(
                  spacing: AppConstants.paddingSM,
                  children: OrderStatus.values.map((status) {
                    final isSelected = order.status == status;
                    return FilterChip(
                      label: Text(_getStatusDisplayName(status)),
                      selected: isSelected,
                      onSelected: isSelected ? null : (_) => onStatusChanged(status),
                      selectedColor: _getStatusColor(status).withOpacity(0.2),
                      checkmarkColor: _getStatusColor(status),
                      side: BorderSide(
                        color: _getStatusColor(status).withOpacity(0.5),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return AppTheme.secondaryColor;
      case OrderStatus.cancelled:
        return AppTheme.errorColor;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        text = 'Pending';
        break;
      case OrderStatus.confirmed:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        text = 'Confirmed';
        break;
      case OrderStatus.shipped:
        backgroundColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        text = 'Shipped';
        break;
      case OrderStatus.delivered:
        backgroundColor = AppTheme.secondaryColor.withOpacity(0.1);
        textColor = AppTheme.secondaryColor;
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        backgroundColor = AppTheme.errorColor.withOpacity(0.1);
        textColor = AppTheme.errorColor;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMD,
        vertical: AppConstants.paddingSM,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}