import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/shop/product_model.dart';
import '../features/shop/product_repository.dart';

class AdminProductFormPage extends ConsumerStatefulWidget {
  const AdminProductFormPage({super.key, this.productId});
  final String? productId;

  @override
  ConsumerState<AdminProductFormPage> createState() => _AdminProductFormPageState();
}

class _AdminProductFormPageState extends ConsumerState<AdminProductFormPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIfEditing();
  }

  Future<void> _loadIfEditing() async {
    if (widget.productId == null) return;
    final repo = buildProductRepository();
    final p = await repo.getProductById(widget.productId!);
    if (p != null && mounted) {
      _titleController.text = p.title;
      _descController.text = p.description;
      _priceController.text = (p.priceCents / 100).toStringAsFixed(2);
      _imageUrlController.text = p.imageUrl;
      setState(() {});
    }
  }

  Future<void> _save() async {
    setState(() { _loading = true; _error = null; });
    try {
      final repo = buildProductRepository();
      final priceCents = (double.tryParse(_priceController.text.trim()) ?? 0) * 100;
      final product = Product(
        id: widget.productId ?? '0',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priceCents: priceCents.toInt(),
        imageUrl: _imageUrlController.text.trim(),
      );
      if (widget.productId == null) {
        await repo.createProduct(product);
        if (mounted) context.go('/admin');
      } else {
        await repo.updateProduct(widget.productId!, product);
        if (mounted) context.go('/admin');
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'New Product')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                ],
                TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 12),
                TextField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 12),
                TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (USD)')),
                const SizedBox(height: 12),
                TextField(controller: _imageUrlController, decoration: const InputDecoration(labelText: 'Image URL')),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _save,
                    child: Text(isEditing ? 'Save Changes' : 'Create Product'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}