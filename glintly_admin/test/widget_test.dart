// Basic Flutter widget test for admin app
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glintly_admin/main.dart';

void main() {
  testWidgets('Admin app builds', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GlintlyAdminApp()));
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
