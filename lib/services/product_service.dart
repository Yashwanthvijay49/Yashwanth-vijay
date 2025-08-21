import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/product_model.dart';

class ProductService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<List<ProductModel>> getProducts({
    String? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      final response = await query;
      return response.map<ProductModel>((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', id)
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('products')
          .select('category')
          .eq('is_active', true);

      final categories = response
          .map<String>((item) => item['category'] as String)
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Admin functions
  Future<ProductModel?> createProduct(ProductModel product) async {
    try {
      final response = await _supabase
          .from('products')
          .insert(product.toJson())
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      print('Error creating product: $e');
      return null;
    }
  }

  Future<ProductModel?> updateProduct(ProductModel product) async {
    try {
      final response = await _supabase
          .from('products')
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      print('Error updating product: $e');
      return null;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _supabase
          .from('products')
          .update({'is_active': false})
          .eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  Future<List<ProductModel>> getAllProductsForAdmin({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<ProductModel>((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching admin products: $e');
      return [];
    }
  }
}