import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      final response = await _supabase
          .from('cart_items')
          .select('*, product:products(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<CartItemModel>((json) => CartItemModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching cart items: $e');
      return [];
    }
  }

  Future<CartItemModel?> addToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    try {
      // Check if item already exists in cart
      final existingItems = await _supabase
          .from('cart_items')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId);

      if (existingItems.isNotEmpty) {
        // Update quantity
        final existingItem = existingItems.first;
        final newQuantity = existingItem['quantity'] + quantity;
        
        final response = await _supabase
            .from('cart_items')
            .update({'quantity': newQuantity})
            .eq('id', existingItem['id'])
            .select('*, product:products(*)')
            .single();

        return CartItemModel.fromJson(response);
      } else {
        // Create new cart item
        final response = await _supabase
            .from('cart_items')
            .insert({
              'user_id': userId,
              'product_id': productId,
              'quantity': quantity,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select('*, product:products(*)')
            .single();

        return CartItemModel.fromJson(response);
      }
    } catch (e) {
      print('Error adding to cart: $e');
      return null;
    }
  }

  Future<CartItemModel?> updateCartItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(cartItemId);
        return null;
      }

      final response = await _supabase
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', cartItemId)
          .select('*, product:products(*)')
          .single();

      return CartItemModel.fromJson(response);
    } catch (e) {
      print('Error updating cart item: $e');
      return null;
    }
  }

  Future<bool> removeFromCart(String cartItemId) async {
    try {
      await _supabase
          .from('cart_items')
          .delete()
          .eq('id', cartItemId);
      return true;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  Future<bool> clearCart(String userId) async {
    try {
      await _supabase
          .from('cart_items')
          .delete()
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  Future<double> getCartTotal(String userId) async {
    try {
      final cartItems = await getCartItems(userId);
      return cartItems.fold<double>(
        0.0,
        (total, item) => total + item.totalPrice,
      );
    } catch (e) {
      print('Error calculating cart total: $e');
      return 0.0;
    }
  }

  Future<int> getCartItemCount(String userId) async {
    try {
      final cartItems = await getCartItems(userId);
      return cartItems.fold<int>(
        0,
        (total, item) => total + item.quantity,
      );
    } catch (e) {
      print('Error getting cart item count: $e');
      return 0;
    }
  }
}