import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../config/app_theme.dart';
import '../../utils/constants.dart';
import '../../models/order_model.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(userOrdersProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: const CustomAppBar(title: 'My Orders'),
      body: orders.when(
        data: (orderList) {
          if (orderList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppConstants.paddingLG),
                  Text(
                    'No orders yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppConstants.paddingMD),
                  Text(
                    'Start shopping to see your orders here',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                  const SizedBox(height: AppConstants.paddingXL),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/'),
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('Start Shopping'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userOrdersProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMD),
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                final order = orderList[index];
                return _OrderCard(
                  order: order,
                  currencyFormat: currencyFormat,
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
                  ref.invalidate(userOrdersProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final NumberFormat currencyFormat;

  const _OrderCard({
    required this.order,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMD),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                _StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMD),

            // Order items preview
            Text(
              'Items (${order.items.fold<int>(0, (sum, item) => sum + item.quantity)})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSM),
            ...order.items.take(2).map((item) => Padding(
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
                              'Qty: ${item.quantity}',
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
            if (order.items.length > 2)
              Text(
                '... and ${order.items.length - 2} more items',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            const Divider(),

            // Order total and shipping
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Shipping to: ${_getShortAddress(order.shippingAddress)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
                Text(
                  currencyFormat.format(order.totalAmount),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getShortAddress(String fullAddress) {
    final parts = fullAddress.split(', ');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2]}, ${parts.last}';
    }
    return fullAddress;
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