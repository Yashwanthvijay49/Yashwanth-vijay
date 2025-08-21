import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/product/product_card.dart';
import '../../config/app_theme.dart';
import '../../utils/constants.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final categories = ref.watch(categoriesProvider);
    final searchFilters = ref.watch(productSearchProvider);
    final products = ref.watch(productsProvider(searchFilters));

    return Scaffold(
      appBar: CustomAppBar(
        title: AppConstants.appName,
        actions: [
          if (userProfile.value?.isAdmin == true)
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/admin'),
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Dashboard',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMD),
            color: AppTheme.surfaceColor,
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              ref.read(productSearchProvider.notifier)
                                  .updateSearchQuery(null);
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    ref.read(productSearchProvider.notifier)
                        .updateSearchQuery(value.isEmpty ? null : value);
                  },
                ),
                const SizedBox(height: AppConstants.paddingMD),

                // Categories
                categories.when(
                  data: (categoryList) => SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: AppConstants.paddingSM),
                            child: FilterChip(
                              label: const Text('All'),
                              selected: _selectedCategory == null,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = null;
                                });
                                ref.read(productSearchProvider.notifier)
                                    .updateCategory(null);
                              },
                            ),
                          );
                        }

                        final category = categoryList[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(right: AppConstants.paddingSM),
                          child: FilterChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? category : null;
                              });
                              ref.read(productSearchProvider.notifier)
                                  .updateCategory(selected ? category : null);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 40,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Products grid
          Expanded(
            child: products.when(
              data: (productList) {
                if (productList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: AppConstants.paddingMD),
                        Text(
                          'No products found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: AppConstants.paddingSM),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(productsProvider(searchFilters));
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingMD),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      childAspectRatio: 0.75,
                      crossAxisSpacing: AppConstants.paddingMD,
                      mainAxisSpacing: AppConstants.paddingMD,
                    ),
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: productList[index]);
                    },
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
                      'Failed to load products',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.errorColor,
                          ),
                    ),
                    const SizedBox(height: AppConstants.paddingSM),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingMD),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(productsProvider(searchFilters));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < AppConstants.mobileBreakpoint) {
      return 2;
    } else if (width < AppConstants.tabletBreakpoint) {
      return 3;
    } else {
      return 4;
    }
  }
}