import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import 'cart_service.dart';

class OrderService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final CartService _cartService = CartService();

  Future<OrderModel?> createOrder({
    required String userId,
    required String shippingAddress,
  }) async {
    try {
      // Get cart items
      final cartItems = await _cartService.getCartItems(userId);
      if (cartItems.isEmpty) {
        throw Exception('Cart is empty');
      }

      final totalAmount = cartItems.fold<double>(
        0.0,
        (total, item) => total + item.totalPrice,
      );

      // Create order
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'user_id': userId,
            'total_amount': totalAmount,
            'status': OrderStatus.pending.name,
            'shipping_address': shippingAddress,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final orderId = orderResponse['id'];

      // Create order items
      final orderItems = cartItems.map((item) => {
            'order_id': orderId,
            'product_id': item.productId,
            'quantity': item.quantity,
            'price': item.product.price,
            'created_at': DateTime.now().toIso8601String(),
          }).toList();

      await _supabase.from('order_items').insert(orderItems);

      // Clear cart
      await _cartService.clearCart(userId);

      // Fetch complete order with items
      return await getOrderById(orderId);
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final orderResponse = await _supabase
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();

      final itemsResponse = await _supabase
          .from('order_items')
          .select('*, product:products(*)')
          .eq('order_id', orderId);

      final items = itemsResponse.map<CartItemModel>((json) {
        return CartItemModel(
          id: json['id'],
          userId: orderResponse['user_id'],
          productId: json['product_id'],
          product: ProductModel.fromJson(json['product']),
          quantity: json['quantity'],
          createdAt: DateTime.parse(json['created_at']),
        );
      }).toList();

      return OrderModel(
        id: orderResponse['id'],
        userId: orderResponse['user_id'],
        items: items,
        totalAmount: (orderResponse['total_amount'] as num).toDouble(),
        status: OrderStatus.values.firstWhere(
          (e) => e.name == orderResponse['status'],
          orElse: () => OrderStatus.pending,
        ),
        shippingAddress: orderResponse['shipping_address'],
        createdAt: DateTime.parse(orderResponse['created_at']),
        updatedAt: DateTime.parse(orderResponse['updated_at']),
      );
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final ordersResponse = await _supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final orders = <OrderModel>[];
      for (final orderJson in ordersResponse) {
        final order = await getOrderById(orderJson['id']);
        if (order != null) {
          orders.add(order);
        }
      }

      return orders;
    } catch (e) {
      print('Error fetching user orders: $e');
      return [];
    }
  }

  // Admin functions
  Future<List<OrderModel>> getAllOrders({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final ordersResponse = await _supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final orders = <OrderModel>[];
      for (final orderJson in ordersResponse) {
        final order = await getOrderById(orderJson['id']);
        if (order != null) {
          orders.add(order);
        }
      }

      return orders;
    } catch (e) {
      print('Error fetching all orders: $e');
      return [];
    }
  }

  Future<OrderModel?> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'status': status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      return await getOrderById(orderId);
    } catch (e) {
      print('Error updating order status: $e');
      return null;
    }
  }
}