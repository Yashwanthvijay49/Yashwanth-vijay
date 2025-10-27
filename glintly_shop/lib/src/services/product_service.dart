import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  ProductService._();
  static final instance = ProductService._();

  Future<List<Product>> fetchProducts() async {
    final res = await Supabase.instance.client.from('products').select().order('created_at');
    return (res as List).map((e) => Product.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<Product?> fetchById(String id) async {
    final res = await Supabase.instance.client.from('products').select().eq('id', id).maybeSingle();
    if (res == null) return null;
    return Product.fromMap(res as Map<String, dynamic>);
  }
}

class Product {
  final String id;
  final String title;
  final String? description;
  final double price;
  final String? imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.description,
    this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      title: map['title'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'] as String?,
    );
  }
}

