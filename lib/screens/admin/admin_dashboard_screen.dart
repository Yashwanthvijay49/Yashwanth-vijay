import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../config/app_theme.dart';
import '../../utils/constants.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Admin Dashboard',
        showBackButton: true,
        showCartIcon: false,
      ),
      body: userProfile.when(
        data: (profile) {
          if (profile == null || !profile.isAdmin) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: 80,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: AppConstants.paddingMD),
                  Text(
                    'Access Denied',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.paddingSM),
                  Text(
                    'You do not have admin privileges',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppConstants.paddingLG),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLG),
                    child: Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: AppConstants.paddingMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${profile.fullName ?? 'Admin'}!',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppConstants.paddingSM),
                              Text(
                                'Manage your store from this dashboard',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLG),

                // Quick stats (placeholder)
                Text(
                  'Quick Stats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingMD),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Products',
                        value: '---',
                        icon: Icons.inventory,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingMD),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Orders',
                        value: '---',
                        icon: Icons.receipt_long,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMD),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Revenue',
                        value: '\$---',
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingMD),
                    Expanded(
                      child: _StatCard(
                        title: 'Users',
                        value: '---',
                        icon: Icons.people,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingXL),

                // Management options
                Text(
                  'Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingMD),
                _AdminMenuItem(
                  icon: Icons.inventory,
                  title: 'Manage Products',
                  subtitle: 'Add, edit, and delete products',
                  onTap: () => context.push('/admin/products'),
                ),
                _AdminMenuItem(
                  icon: Icons.receipt_long,
                  title: 'Manage Orders',
                  subtitle: 'View and update order status',
                  onTap: () => context.push('/admin/orders'),
                ),
                _AdminMenuItem(
                  icon: Icons.analytics,
                  title: 'Analytics',
                  subtitle: 'View sales and performance metrics',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Analytics feature coming soon!'),
                      ),
                    );
                  },
                ),
                _AdminMenuItem(
                  icon: Icons.people,
                  title: 'User Management',
                  subtitle: 'Manage user accounts and permissions',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User management feature coming soon!'),
                      ),
                    );
                  },
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
                'Failed to load dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.errorColor,
                    ),
              ),
              const SizedBox(height: AppConstants.paddingMD),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userProfileProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: AppConstants.iconMD,
                ),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSM),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMD),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConstants.paddingMD),
        leading: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMD),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: AppConstants.iconMD,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}