import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/main.dart';

void main() {
  testWidgets('App starts and shows splash screen', (tester) async {
    await tester.pumpWidget(const MarketplaceApp());
    expect(find.text('Marketplace Locale'), findsOneWidget);
  });
}
