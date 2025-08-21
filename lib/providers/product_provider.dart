import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) => ProductService());

final productsProvider = FutureProvider.family<List<ProductModel>, ProductFilters>((ref, filters) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getProducts(
    category: filters.category,
    searchQuery: filters.searchQuery,
    limit: filters.limit,
    offset: filters.offset,
  );
});

final productProvider = FutureProvider.family<ProductModel?, String>((ref, productId) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getProductById(productId);
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getCategories();
});

class ProductFilters {
  final String? category;
  final String? searchQuery;
  final int limit;
  final int offset;

  const ProductFilters({
    this.category,
    this.searchQuery,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductFilters &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          searchQuery == other.searchQuery &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode =>
      category.hashCode ^
      searchQuery.hashCode ^
      limit.hashCode ^
      offset.hashCode;
}

class ProductSearchNotifier extends StateNotifier<ProductFilters> {
  ProductSearchNotifier() : super(const ProductFilters());

  void updateCategory(String? category) {
    state = ProductFilters(
      category: category,
      searchQuery: state.searchQuery,
      limit: state.limit,
      offset: 0, // Reset offset when changing filters
    );
  }

  void updateSearchQuery(String? searchQuery) {
    state = ProductFilters(
      category: state.category,
      searchQuery: searchQuery,
      limit: state.limit,
      offset: 0, // Reset offset when changing filters
    );
  }

  void clearFilters() {
    state = const ProductFilters();
  }

  void loadMore() {
    state = ProductFilters(
      category: state.category,
      searchQuery: state.searchQuery,
      limit: state.limit,
      offset: state.offset + state.limit,
    );
  }
}

final productSearchProvider = StateNotifierProvider<ProductSearchNotifier, ProductFilters>((ref) {
  return ProductSearchNotifier();
});

// Admin providers
final adminProductsProvider = FutureProvider.family<List<ProductModel>, AdminProductFilters>((ref, filters) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getAllProductsForAdmin(
    limit: filters.limit,
    offset: filters.offset,
  );
});

class AdminProductFilters {
  final int limit;
  final int offset;

  const AdminProductFilters({
    this.limit = 50,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminProductFilters &&
          runtimeType == other.runtimeType &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode => limit.hashCode ^ offset.hashCode;
}