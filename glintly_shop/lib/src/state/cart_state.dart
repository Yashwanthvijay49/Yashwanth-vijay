import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartState {
  final List<CartItem> items;
  const CartState({this.items = const []});

  double get total => items.fold(0, (sum, i) => sum + i.product.price * i.quantity);
}

class CartItem {
  final Product product;
  final int quantity;
  const CartItem({required this.product, required this.quantity});
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void add(Product product) {
    final existingIndex = state.items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      final updated = [...state.items];
      final existing = updated[existingIndex];
      updated[existingIndex] = CartItem(product: existing.product, quantity: existing.quantity + 1);
      state = CartState(items: updated);
    } else {
      state = CartState(items: [...state.items, CartItem(product: product, quantity: 1)]);
    }
  }

  void remove(Product product) {
    state = CartState(items: state.items.where((i) => i.product.id != product.id).toList());
  }

  void setQuantity(Product product, int quantity) {
    if (quantity <= 0) return remove(product);
    final updated = state.items
        .map((i) => i.product.id == product.id ? CartItem(product: i.product, quantity: quantity) : i)
        .toList();
    state = CartState(items: updated);
  }

  void clear() => state = const CartState(items: []);
}

