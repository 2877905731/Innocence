import 'package:flutter/material.dart';

/// Warm paper backdrop for the citrus-white theme. The historical widget name
/// remains to keep existing callers stable while the stored theme id migrates
/// visually from soft spectrum to minimal white.
class SoftSpectrumBackdrop extends StatelessWidget {
  const SoftSpectrumBackdrop({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFEEEDE9)),
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
    final warmth = Rect.fromCircle(
      center: Offset(size.width * .82, size.height * .10),
      radius: size.longestSide * .56,
    );
    canvas.drawOval(
      warmth,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x85E8DFD4), Color(0x00E8DFD4)],
        ).createShader(warmth),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
