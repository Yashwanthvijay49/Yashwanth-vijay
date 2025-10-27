import 'package:flutter/material.dart';
import 'package:glintly_ui/glintly_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final imageUrlController = TextEditingController();
  bool loading = false;
  String? error;
  String? success;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'New Product',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.red)),
                if (success != null)
                  Text(success!, style: const TextStyle(color: Colors.green)),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL (optional)'),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Create product',
                  loading: loading,
                  onPressed: _create,
                  icon: Icons.save_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _create() async {
    setState(() {
      loading = true;
      error = null;
      success = null;
    });
    try {
      final price = double.tryParse(priceController.text) ?? 0;
      await Supabase.instance.client.from('products').insert({
        'title': titleController.text,
        'description': descriptionController.text,
        'price': price,
        'image_url': imageUrlController.text.isEmpty ? null : imageUrlController.text,
      });
      setState(() => success = 'Product created');
    } catch (e) {
      setState(() => error = 'Failed to create product');
    } finally {
      setState(() => loading = false);
    }
  }
}

