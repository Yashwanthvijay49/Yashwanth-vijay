import 'package:equatable/equatable.dart';
import '../shop/product_model.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});
  final Product product;
  final int quantity;

  CartItem copyWith({Product? product, int? quantity}) => CartItem(
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
      );

  int get lineTotalCents => product.priceCents * quantity;

  @override
  List<Object?> get props => [product, quantity];
}