import 'package:flutter/material.dart';

/// Shared background for the soft-spectrum editorial theme.
///
/// The legacy storage id remains `minimalism`, but its visible expression is
/// now a pale editorial grid with lavender and coral color fields.
class SoftSpectrumBackdrop extends StatelessWidget {
  const SoftSpectrumBackdrop({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFF4F4F7)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const IgnorePointer(
            child: CustomPaint(painter: _SoftSpectrumBackdropPainter()),
          ),
          child,
        ],
      ),
    );
  }
}

class _SoftSpectrumBackdropPainter extends CustomPainter {
  const _SoftSpectrumBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFF17181B).withValues(alpha: 0.026)
      ..strokeWidth = 1;
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final lavenderRect = Rect.fromLTWH(
      size.width * 0.55,
      -size.height * 0.16,
      size.width * 0.50,
      size.height * 0.46,
    );
    final lavender = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x5C8E7DFF), Color(0x00E7E2FF)],
      ).createShader(lavenderRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(lavenderRect, const Radius.circular(72)),
      lavender,
    );

    final coralRect = Rect.fromLTWH(
      size.width * 0.72,
      size.height * 0.70,
      size.width * 0.36,
      size.height * 0.34,
    );
    final coral = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x4DFF9CA9), Color(0x00FFF0F2)],
      ).createShader(coralRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(coralRect, const Radius.circular(64)),
      coral,
    );

    final glowRect = Rect.fromCircle(
      center: Offset(size.width * 0.08, size.height * 0.84),
      radius: size.shortestSide * 0.22,
    );
    final glow = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x2B8E7DFF), Color(0x008E7DFF)],
      ).createShader(glowRect);
    canvas.drawCircle(glowRect.center, glowRect.width / 2, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
