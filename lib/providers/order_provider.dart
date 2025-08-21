import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'auth_provider.dart';

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

final userOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  final orderService = ref.read(orderServiceProvider);
  return await orderService.getUserOrders(user.id);
});

final orderProvider = FutureProvider.family<OrderModel?, String>((ref, orderId) async {
  final orderService = ref.read(orderServiceProvider);
  return await orderService.getOrderById(orderId);
});

class OrderNotifier extends StateNotifier<AsyncValue<OrderModel?>> {
  final OrderService _orderService;
  final Ref _ref;

  OrderNotifier(this._orderService, this._ref) : super(const AsyncValue.data(null));

  Future<OrderModel?> createOrder({
    required String userId,
    required String shippingAddress,
  }) async {
    state = const AsyncValue.loading();
    try {
      final order = await _orderService.createOrder(
        userId: userId,
        shippingAddress: shippingAddress,
      );
      
      if (order != null) {
        state = AsyncValue.data(order);
        
        // Invalidate user orders to refresh the list
        _ref.invalidate(userOrdersProvider);
        
        return order;
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  void clearCurrentOrder() {
    state = const AsyncValue.data(null);
  }
}

final orderNotifierProvider = StateNotifierProvider<OrderNotifier, AsyncValue<OrderModel?>>((ref) {
  final orderService = ref.read(orderServiceProvider);
  return OrderNotifier(orderService, ref);
});

// Admin providers
final adminOrdersProvider = FutureProvider.family<List<OrderModel>, AdminOrderFilters>((ref, filters) async {
  final orderService = ref.read(orderServiceProvider);
  return await orderService.getAllOrders(
    limit: filters.limit,
    offset: filters.offset,
  );
});

class AdminOrderFilters {
  final int limit;
  final int offset;

  const AdminOrderFilters({
    this.limit = 50,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminOrderFilters &&
          runtimeType == other.runtimeType &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode => limit.hashCode ^ offset.hashCode;
}

class AdminOrderNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrderService _orderService;

  AdminOrderNotifier(this._orderService) : super(const AsyncValue.loading());

  Future<void> loadOrders({int limit = 50, int offset = 0}) async {
    state = const AsyncValue.loading();
    try {
      final orders = await _orderService.getAllOrders(limit: limit, offset: offset);
      state = AsyncValue.data(orders);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    try {
      await _orderService.updateOrderStatus(orderId: orderId, status: status);
      
      // Reload orders
      await loadOrders();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final adminOrderNotifierProvider = StateNotifierProvider<AdminOrderNotifier, AsyncValue<List<OrderModel>>>((ref) {
  final orderService = ref.read(orderServiceProvider);
  return AdminOrderNotifier(orderService);
});