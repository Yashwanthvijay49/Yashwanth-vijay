import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../models/product_model.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';
import '../../config/app_theme.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId;

  const AddEditProductScreen({
    super.key,
    this.productId,
  });

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _stockController = TextEditingController();
  
  String _selectedCategory = AppConstants.productCategories.first;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isSaving = false;
  ProductModel? _existingProduct;

  bool get isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadProduct();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    if (widget.productId == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final productService = ref.read(productServiceProvider);
      final product = await productService.getProductById(widget.productId!);
      
      if (product != null) {
        setState(() {
          _existingProduct = product;
          _nameController.text = product.name;
          _descriptionController.text = product.description;
          _priceController.text = product.price.toString();
          _imageUrlController.text = product.imageUrl ?? '';
          _stockController.text = product.stock.toString();
          _selectedCategory = product.category;
          _isActive = product.isActive;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load product: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Product' : 'Add Product',
        showBackButton: true,
        showCartIcon: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLG),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product name
                    TextFormField(
                      controller: _nameController,
                      validator: (value) => Validators.required(value, 'Product name'),
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMD),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      validator: (value) => Validators.required(value, 'Description'),
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMD),

                    // Price and Stock
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            validator: (value) => Validators.positiveNumber(value, 'Price'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Price (\$)',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMD),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            validator: (value) => Validators.positiveInteger(value, 'Stock'),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Stock Quantity',
                              prefixIcon: Icon(Icons.inventory),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMD),

                    // Category
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: AppConstants.productCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppConstants.paddingMD),

                    // Image URL
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL (Optional)',
                        prefixIcon: Icon(Icons.image),
                        hintText: 'https://example.com/image.jpg',
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMD),

                    // Active status
                    SwitchListTile(
                      title: const Text('Product Active'),
                      subtitle: Text(_isActive ? 'Product is visible to customers' : 'Product is hidden from customers'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: AppConstants.paddingXL),

                    // Save button
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.paddingMD,
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(isEditing ? 'Update Product' : 'Create Product'),
                    ),

                    if (isEditing) ...[
                      const SizedBox(height: AppConstants.paddingMD),
                      OutlinedButton(
                        onPressed: _isSaving ? null : () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final productService = ref.read(productServiceProvider);
      final now = DateTime.now();
      
      final product = ProductModel(
        id: isEditing ? _existingProduct!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        category: _selectedCategory,
        stock: int.parse(_stockController.text),
        isActive: _isActive,
        createdAt: isEditing ? _existingProduct!.createdAt : now,
        updatedAt: now,
      );

      ProductModel? result;
      if (isEditing) {
        result = await productService.updateProduct(product);
      } else {
        result = await productService.createProduct(product);
      }

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing 
                  ? 'Product updated successfully' 
                  : 'Product created successfully',
            ),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
        
        // Invalidate products list to refresh
        ref.invalidate(adminProductsProvider(const AdminProductFilters()));
        
        // Go back to products list
        context.pop();
      } else {
        throw Exception(isEditing ? 'Failed to update product' : 'Failed to create product');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}