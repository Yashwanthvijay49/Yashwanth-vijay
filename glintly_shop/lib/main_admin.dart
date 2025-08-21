import 'bootstrap.dart';
import 'app/app.dart';
import 'app/navigation_config.dart';

Future<void> main() async {
  await bootstrap(
    () async => const GlintlyApp(),
    overrides: [
      adminModeProvider.overrideWithValue(true),
      initialLocationProvider.overrideWithValue('/admin'),
    ],
  );
}