import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/order_store.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final store = OrderStore();
        unawaited(store.load());
        return store;
      },
      child: const OrderlyApp(),
    ),
  );
}

class OrderlyApp extends StatelessWidget {
  const OrderlyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Orderly',
    debugShowCheckedModeBanner: false,
    theme: OrderlyTheme.light,
    home: const SplashScreen(),
  );
}
