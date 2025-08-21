import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../config/app_theme.dart';
import '../../utils/constants.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productProvider(widget.productId));
    final user = ref.watch(currentUserProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Product Details',
        showBackButton: true,
      ),
      body: product.when(
        data: (productData) {
          if (productData == null) {
            return const Center(
              child: Text('Product not found'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                AspectRatio(
                  aspectRatio: 1.0,
                  child: CachedNetworkImage(
                    imageUrl: productData.imageUrl ?? AppConstants.productPlaceholder,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                // Product details
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMD,
                          vertical: AppConstants.paddingSM,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                        ),
                        child: Text(
                          productData.category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMD),

                      // Product name
                      Text(
                        productData.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppConstants.paddingMD),

                      // Price
                      Text(
                        currencyFormat.format(productData.price),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppConstants.paddingMD),

                      // Stock status
                      Row(
                        children: [
                          Icon(
                            productData.stock > 0
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: productData.stock > 0
                                ? AppTheme.secondaryColor
                                : AppTheme.errorColor,
                            size: AppConstants.iconMD,
                          ),
                          const SizedBox(width: AppConstants.paddingSM),
                          Text(
                            productData.stock > 0
                                ? 'In Stock (${productData.stock} available)'
                                : 'Out of Stock',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: productData.stock > 0
                                      ? AppTheme.secondaryColor
                                      : AppTheme.errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingLG),

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppConstants.paddingMD),
                      Text(
                        productData.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                            ),
                      ),
                      const SizedBox(height: AppConstants.paddingXL),

                      // Quantity selector and Add to Cart
                      if (user != null && productData.stock > 0) ...[
                        Row(
                          children: [
                            Text(
                              'Quantity:',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: AppConstants.paddingMD),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderColor),
                                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: _quantity > 1
                                        ? () => setState(() => _quantity--)
                                        : null,
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Container(
                                    constraints: const BoxConstraints(minWidth: 40),
                                    child: Text(
                                      _quantity.toString(),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _quantity < productData.stock
                                        ? () => setState(() => _quantity++)
                                        : null,
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingXL),

                        // Add to Cart button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _addToCart(productData.id),
                            icon: const Icon(Icons.add_shopping_cart),
                            label: Text(
                              'Add to Cart - ${currencyFormat.format(productData.price * _quantity)}',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.paddingMD,
                              ),
                            ),
                          ),
                        ),
                      ] else if (user == null) ...[
                        // Login prompt
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppConstants.paddingLG),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.account_circle,
                                size: 48,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: AppConstants.paddingMD),
                              Text(
                                'Sign in to add items to your cart',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.paddingMD),
                              ElevatedButton(
                                onPressed: () => Navigator.pushNamed(context, '/login'),
                                child: const Text('Sign In'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: AppConstants.paddingMD),
              Text(
                'Failed to load product',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.errorColor,
                    ),
              ),
              const SizedBox(height: AppConstants.paddingMD),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(productProvider(widget.productId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart(String productId) async {
    try {
      await ref.read(cartNotifierProvider.notifier).addToCart(
            productId: productId,
            quantity: _quantity,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $_quantity item(s) to cart'),
            backgroundColor: AppTheme.secondaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to add item to cart'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}