import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';
import 'auth_provider.dart';

final cartServiceProvider = Provider<CartService>((ref) => CartService());

final cartItemsProvider = FutureProvider<List<CartItemModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  final cartService = ref.read(cartServiceProvider);
  return await cartService.getCartItems(user.id);
});

final cartTotalProvider = FutureProvider<double>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0.0;
  
  final cartService = ref.read(cartServiceProvider);
  return await cartService.getCartTotal(user.id);
});

final cartItemCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  
  final cartService = ref.read(cartServiceProvider);
  return await cartService.getCartItemCount(user.id);
});

class CartNotifier extends StateNotifier<AsyncValue<List<CartItemModel>>> {
  final CartService _cartService;
  final String? _userId;
  final Ref _ref;

  CartNotifier(this._cartService, this._userId, this._ref) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      _loadCartItems();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> _loadCartItems() async {
    if (_userId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final items = await _cartService.getCartItems(_userId!);
      state = AsyncValue.data(items);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    if (_userId == null) return;

    try {
      await _cartService.addToCart(
        userId: _userId!,
        productId: productId,
        quantity: quantity,
      );
      
      // Refresh cart items
      await _loadCartItems();
      
      // Invalidate related providers
      _ref.invalidate(cartTotalProvider);
      _ref.invalidate(cartItemCountProvider);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      await _cartService.updateCartItemQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      
      // Refresh cart items
      await _loadCartItems();
      
      // Invalidate related providers
      _ref.invalidate(cartTotalProvider);
      _ref.invalidate(cartItemCountProvider);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _cartService.removeFromCart(cartItemId);
      
      // Refresh cart items
      await _loadCartItems();
      
      // Invalidate related providers
      _ref.invalidate(cartTotalProvider);
      _ref.invalidate(cartItemCountProvider);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> clearCart() async {
    if (_userId == null) return;

    try {
      await _cartService.clearCart(_userId!);
      
      // Refresh cart items
      await _loadCartItems();
      
      // Invalidate related providers
      _ref.invalidate(cartTotalProvider);
      _ref.invalidate(cartItemCountProvider);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final cartNotifierProvider = StateNotifierProvider<CartNotifier, AsyncValue<List<CartItemModel>>>((ref) {
  final cartService = ref.read(cartServiceProvider);
  final user = ref.watch(currentUserProvider);
  return CartNotifier(cartService, user?.id, ref);
});