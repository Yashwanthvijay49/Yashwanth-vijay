import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  List<Override> overrides = const [],
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!hasSupabaseConfig) {
    debugPrint('WARNING: Missing SUPABASE_URL or SUPABASE_ANON_KEY. Provide with --dart-define.');
  }

  if (hasSupabaseConfig) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  runApp(
    ProviderScope(
      overrides: overrides,
      child: await builder(),
    ),
  );
}