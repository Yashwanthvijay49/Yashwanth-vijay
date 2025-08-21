import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glintly_ui/glintly_ui.dart';
import 'package:go_router/go_router.dart';
import '../../services/product_service.dart';
import '../../state/cart_state.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  Product? product;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ProductService.instance.fetchById(widget.productId);
    setState(() {
      product = p;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: product?.title ?? 'Product',
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () => context.go('/cart'),
        )
      ],
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? const EmptyState(icon: Icons.error_outline, title: 'Product not found')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product!.imageUrl != null)
                        AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(product!.imageUrl!, fit: BoxFit.cover),
                        ),
                      const SizedBox(height: 16),
                      Text(product!.title, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      if (product!.description != null)
                        Text(product!.description!, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      Text('\$${product!.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Add to cart',
                        icon: Icons.add_shopping_cart,
                        onPressed: () => ref.read(cartProvider.notifier).add(product!),
                      )
                    ],
                  ),
                ),
    );
  }
}

