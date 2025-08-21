import 'bootstrap.dart';
import 'app/app.dart';

Future<void> main() async {
  await bootstrap(() async => const GlintlyApp());
}
