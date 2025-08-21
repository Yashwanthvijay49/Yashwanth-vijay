import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glintly_ui/glintly_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL', fallback: ''),
    anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: ''),
  );
  runApp(const ProviderScope(child: GlintlyAdminApp()));
}

class GlintlyAdminApp extends ConsumerWidget {
  const GlintlyAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(adminRouterProvider);
    return MaterialApp.router(
      title: 'Glintly Admin',
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}

