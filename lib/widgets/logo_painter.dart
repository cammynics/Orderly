import 'package:flutter/material.dart';

import '../utils/theme.dart';

class LogoPainter extends CustomPainter {
  const LogoPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final heart = _heartPath(size);
    final strokeWidth = size.shortestSide * 0.065;
    final metric = heart.computeMetrics().first;
    final completeHeart = metric.extractPath(0, metric.length);

    canvas.drawPath(
      completeHeart,
      Paint()
        ..color = OrderlyTheme.splashShadow
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawPath(
      completeHeart,
      Paint()
        ..color = OrderlyTheme.splashBadgeBase
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final drawLength = metric.length * progress.clamp(0.0, 1.0);
    if (drawLength > 0) {
      canvas.drawPath(
        metric.extractPath(0, drawLength),
        Paint()
          ..shader = OrderlyTheme.splashFillGradient.createShader(bounds)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  Path _heartPath(Size size) {
    final width = size.width;
    final height = size.height;
    return Path()
      ..moveTo(width * 0.5, height * 0.3)
      ..cubicTo(
        width * 0.38,
        height * 0.08,
        width * 0.15,
        height * 0.08,
        width * 0.08,
        height * 0.27,
      )
      ..cubicTo(
        width * -0.01,
        height * 0.5,
        width * 0.2,
        height * 0.75,
        width * 0.5,
        height * 0.93,
      )
      ..cubicTo(
        width * 0.8,
        height * 0.75,
        width * 1.01,
        height * 0.5,
        width * 0.92,
        height * 0.27,
      )
      ..cubicTo(
        width * 0.85,
        height * 0.08,
        width * 0.62,
        height * 0.08,
        width * 0.5,
        height * 0.3,
      );
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
