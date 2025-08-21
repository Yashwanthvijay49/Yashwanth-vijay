import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme.dart';

final adminModeProvider = Provider<bool>((ref) => false);

class GlintlyApp extends ConsumerWidget {
  const GlintlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Glintly Shop',
      theme: buildLightTheme(),
      routerConfig: router,
    );
  }
}