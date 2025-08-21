import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shop/product_model.dart';
import 'cart_item.dart';

final cartControllerProvider = StateNotifierProvider<CartController, List<CartItem>>(
  (ref) => CartController(),
);

class CartController extends StateNotifier<List<CartItem>> {
  CartController() : super(const []);

  void addProduct(Product product) {
    final index = state.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = updated[index].copyWith(quantity: updated[index].quantity + 1);
      state = updated;
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void removeProduct(String productId) {
    state = state.where((e) => e.product.id != productId).toList();
  }

  void decrementProduct(String productId) {
    final index = state.indexWhere((e) => e.product.id == productId);
    if (index >= 0) {
      final item = state[index];
      if (item.quantity <= 1) {
        removeProduct(productId);
      } else {
        final updated = [...state];
        updated[index] = updated[index].copyWith(quantity: item.quantity - 1);
        state = updated;
      }
    }
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) return removeProduct(productId);
    final index = state.indexWhere((e) => e.product.id == productId);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = updated[index].copyWith(quantity: quantity);
      state = updated;
    }
  }

  void clear() {
    state = const [];
  }

  int totalCents() => state.fold(0, (sum, e) => sum + e.lineTotalCents);
}