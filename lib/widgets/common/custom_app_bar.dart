import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../config/app_theme.dart';
import '../../utils/constants.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showCartIcon;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showCartIcon = true,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemCount = ref.watch(cartItemCountProvider);

    return AppBar(
      title: Text(title),
      leading: showBackButton
          ? IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            )
          : null,
      actions: [
        if (showCartIcon) ...[
          cartItemCount.when(
            data: (count) => Stack(
              children: [
                IconButton(
                  onPressed: () => context.push('/cart'),
                  icon: const Icon(Icons.shopping_cart_outlined),
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            loading: () => IconButton(
              onPressed: () => context.push('/cart'),
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
            error: (_, __) => IconButton(
              onPressed: () => context.push('/cart'),
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
        if (actions != null) ...actions!,
        const SizedBox(width: AppConstants.paddingSM),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}