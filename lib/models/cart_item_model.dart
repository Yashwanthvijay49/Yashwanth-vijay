import 'product_model.dart';

class CartItemModel {
  final String id;
  final String userId;
  final String productId;
  final ProductModel product;
  final int quantity;
  final DateTime createdAt;

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.createdAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get totalPrice => product.price * quantity;

  CartItemModel copyWith({
    String? id,
    String? userId,
    String? productId,
    ProductModel? product,
    int? quantity,
    DateTime? createdAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}