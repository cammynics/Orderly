import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_store.dart';
import '../utils/theme.dart';
import '../widgets/logo_painter.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _breathingController;
  late final Animation<double> _progress;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  bool _initializationComplete = false;
  bool _animationComplete = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _progress = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0, 0.84, curve: Curves.easeInOutCubic),
    );
    _opacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0, 0.12, curve: Curves.easeOut),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.85,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 12,
      ),
      TweenSequenceItem(tween: ConstantTween(1), weight: 72),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.08,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 8,
      ),
    ]).animate(_introController);
    _introController.addStatusListener(_handleIntroStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_initializeStore());
    });
    _introController.forward();
  }

  Future<void> _initializeStore() async {
    await context.read<OrderStore>().load();
    if (!mounted) return;
    _initializationComplete = true;
    _breathingController.stop();
    _maybeNavigate();
  }

  void _handleIntroStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _animationComplete = true;
    if (!_initializationComplete) {
      _breathingController.repeat(reverse: true);
    }
    _maybeNavigate();
  }

  void _maybeNavigate() {
    if (!_animationComplete || !_initializationComplete || _hasNavigated) {
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
    _introController
      ..removeStatusListener(_handleIntroStatus)
      ..dispose();
    _breathingController.dispose();
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
            final heartSize = (constraints.maxWidth * 0.3)
                .clamp(72.0, 180.0)
                .toDouble();
            return Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _introController,
                  _breathingController,
                ]),
                builder: (context, child) {
                  final breathingScale =
                      _animationComplete && !_initializationComplete
                      ? 1 + 0.025 * _breathingController.value
                      : 1.0;
                  return Opacity(
                    opacity: _opacity.value,
                    child: Transform.scale(
                      scale: _scale.value * breathingScale,
                      child: CustomPaint(
                        size: Size.square(heartSize),
                        painter: LogoPainter(progress: _progress.value),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    ),
  );
}
