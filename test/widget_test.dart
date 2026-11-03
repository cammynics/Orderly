import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orderly/providers/order_store.dart';
import 'package:orderly/screens/main_shell.dart';
import 'package:orderly/screens/splash_screen.dart';
import 'package:orderly/utils/validators.dart';
import 'package:orderly/widgets/logo_painter.dart';

void main() {
  testWidgets('splash initializes before navigating to Orders', (tester) async {
    final store = OrderStore();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => store,
        child: const MaterialApp(home: SplashScreen()),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(SplashScreen), findsOneWidget);
    final logoFinder = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is LogoPainter,
    );
    expect(tester.getSize(logoFinder).width, greaterThan(0));

    await tester.pump(const Duration(milliseconds: 250));
    final painter = tester.widget<CustomPaint>(logoFinder).painter!;
    expect((painter as LogoPainter).progress, greaterThan(0));

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(store.isLoading, isFalse);
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
