import 'package:flutter/material.dart';
import 'package:glintly_ui/glintly_ui.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Admin Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.list_alt_outlined),
          onPressed: () => context.go('/orders'),
        ),
        IconButton(
          icon: const Icon(Icons.add_box_outlined),
          onPressed: () => context.go('/products/new'),
        ),
      ],
      body: const Center(
        child: Text('Welcome to Glintly Admin'),
      ),
    );
  }
}

