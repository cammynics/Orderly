import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_store.dart';
import '../utils/theme.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final OrderStore _store;
  Timer? _timer;
  bool _minimumDurationElapsed = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _store = context.read<OrderStore>()..addListener(_maybeNavigate);
    _timer = Timer(const Duration(seconds: 5), () {
      _minimumDurationElapsed = true;
      _maybeNavigate();
    });
  }

  void _maybeNavigate() {
    if (!mounted ||
        !_minimumDurationElapsed ||
        _store.isLoading ||
        _hasNavigated) {
      return;
    }
    _hasNavigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _store.removeListener(_maybeNavigate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: OrderlyTheme.splashBackgroundGradient,
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final iconSize = (constraints.maxWidth * 0.3)
                .clamp(72.0, 180.0)
                .toDouble();
            return Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(iconSize * 0.28),
                child: Transform.scale(
                  scale: 1.15,
                  child: Image.asset(
                    'assets/orderly_app_icon.png',
                    key: const ValueKey('orderly-splash-icon'),
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}