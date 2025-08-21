import 'package:supabase_flutter/supabase_flutter.dart';

import 'product_model.dart';

class ProductRepository {
  ProductRepository(this._client);
  final SupabaseClient _client;

  Future<List<Product>> listProducts() async {
    final response = await _client.from('products').select().order('title');
    return (response as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final response = await _client.from('products').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return Product.fromJson(response as Map<String, dynamic>);
  }

  // Admin methods
  Future<String> createProduct(Product product) async {
    final data = await _client.from('products').insert(product.toJson()).select('id').single();
    return data['id'].toString();
  }

  Future<void> updateProduct(String id, Product product) async {
    await _client.from('products').update(product.toJson()).eq('id', id);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }
}

ProductRepository buildProductRepository() => ProductRepository(Supabase.instance.client);