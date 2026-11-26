import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orderly/providers/order_store.dart';
import 'package:orderly/screens/main_shell.dart';
import 'package:orderly/screens/splash_screen.dart';
import 'package:orderly/main.dart';
import 'package:orderly/utils/validators.dart';

void main() {
  testWidgets('splash shows the app icon for 5 seconds before Orders', (
    tester,
  ) async {
    final store = OrderStore();
    await store.load();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: store,
        child: const OrderlyApp(),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(store.isLoading, isFalse);
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(ClipRRect), findsOneWidget);
    final icon = tester.widget<Image>(
      find.byKey(const ValueKey('orderly-splash-icon')),
    );
    expect((icon.image as AssetImage).assetName, 'assets/orderly_app_icon.png');
    await tester.pump(const Duration(seconds: 4));
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(MainShell), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('AppValidators', () {
    test('requires customer and product text', () {
      expect(AppValidators.requiredText('  ', 'Name'), 'Name is required');
      expect(AppValidators.requiredText('Mina', 'Name'), isNull);
    });

    test('accepts plausible phone numbers and rejects short values', () {
      expect(AppValidators.phone('+63 912 345 6789'), isNull);
      expect(AppValidators.phone('123'), 'Enter a valid contact number');
    });

    test('validates positive quantity and non-negative price', () {
      expect(AppValidators.positiveInteger('2'), isNull);
      expect(AppValidators.positiveInteger('0'), 'Enter a quantity above 0');
      expect(AppValidators.nonNegativePrice('0'), isNull);
      expect(AppValidators.nonNegativePrice('-1'), 'Enter a valid price');
    });
  });
}
