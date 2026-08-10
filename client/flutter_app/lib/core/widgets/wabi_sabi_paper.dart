import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A quiet, deterministic paper surface for the wabi-sabi theme.
///
/// The painter stays deliberately low contrast: short fibres, a loose linen
/// weave and a few broad brush traces should be felt before they are noticed.
class WabiSabiPaper extends StatelessWidget {
  const WabiSabiPaper({
    super.key,
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: CustomPaint(
        painter: const _WabiSabiPaperPainter(),
        child: child,
      ),
    );
  }
}

class _WabiSabiPaperPainter extends CustomPainter {
  const _WabiSabiPaperPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final darkFibre = Paint()
      ..color = const Color(0xFF604B39).withValues(alpha: 0.055)
      ..strokeCap = StrokeCap.round;
    final lightFibre = Paint()
      ..color = const Color(0xFFFFFBF1).withValues(alpha: 0.22)
      ..strokeCap = StrokeCap.round;
    final weave = Paint()
      ..color = const Color(0xFF7C6650).withValues(alpha: 0.025)
      ..strokeWidth = 0.7;

    for (double y = 10; y < size.height; y += 18) {
      final path = Path()..moveTo(0, y);
      for (double x = 32; x <= size.width + 32; x += 32) {
        path.lineTo(x, y + math.sin((x + y) * 0.035) * 1.15);
      }
      canvas.drawPath(path, weave);
    }
    for (double x = 14; x < size.width; x += 22) {
      final path = Path()..moveTo(x, 0);
      for (double y = 36; y <= size.height + 36; y += 36) {
        path.lineTo(x + math.sin((x - y) * 0.028) * 0.9, y);
      }
      canvas.drawPath(path, weave);
    }

    final random = math.Random(19490217);
    final area = size.width * size.height;
    final fibreCount = (area / 4200).round().clamp(90, 360);
    for (var i = 0; i < fibreCount; i++) {
      final start = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final length = 5 + random.nextDouble() * 24;
      final angle = (random.nextDouble() - 0.5) * 0.38;
      final paint = i.isEven ? darkFibre : lightFibre;
      paint.strokeWidth = 0.45 + random.nextDouble() * 0.75;
      canvas.drawLine(
        start,
        start + Offset(math.cos(angle) * length, math.sin(angle) * length),
        paint,
      );
    }

    final brush = Paint()
      ..color = const Color(0xFF725944).withValues(alpha: 0.028)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final brushPaths = <Path>[
      Path()
        ..moveTo(size.width * 0.04, size.height * 0.19)
        ..quadraticBezierTo(
          size.width * 0.36,
          size.height * 0.15,
          size.width * 0.62,
          size.height * 0.2,
        ),
      Path()
        ..moveTo(size.width * 0.52, size.height * 0.78)
        ..quadraticBezierTo(
          size.width * 0.76,
          size.height * 0.73,
          size.width * 0.96,
          size.height * 0.76,
        ),
    ];
    for (var i = 0; i < brushPaths.length; i++) {
      brush.strokeWidth = i == 0 ? 16 : 11;
      canvas.drawPath(brushPaths[i], brush);
    }

    final envelopeFold = Paint()
      ..color = const Color(0xFF6C5541).withValues(alpha: 0.035)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * 0.72, size.height),
      Offset(size.width, size.height * 0.72),
      envelopeFold,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, size.height),
      Offset(size.width, size.height * 0.8),
      envelopeFold,
    );
  }

  @override
  bool shouldRepaint(covariant _WabiSabiPaperPainter oldDelegate) => false;
}
