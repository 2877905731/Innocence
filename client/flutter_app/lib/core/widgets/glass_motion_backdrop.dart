import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared animated background for the glass visual theme.
///
/// Keeping it above page-level surfaces ensures every glass page uses the
/// same moving light field instead of falling back to a static navy canvas.
class GlassMotionBackdrop extends StatefulWidget {
  const GlassMotionBackdrop({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<GlassMotionBackdrop> createState() => _GlassMotionBackdropState();
}

class _GlassMotionBackdropState extends State<GlassMotionBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller
        ..stop()
        ..value = 0.18;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF173B91), Color(0xFF5424B6), Color(0xFFBE4D9B)],
          stops: [0, .52, 1],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _GlassMotionPainter(_controller.value),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

class _GlassMotionPainter extends CustomPainter {
  const _GlassMotionPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = const Color(0x0EFFFFFF);
    for (double x = 0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height * .72), grid);
    }
    for (double y = 0; y < size.height * .72; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final phase = t * math.pi * 2;
    _orb(
      canvas,
      Offset(
        size.width * .16 + math.sin(phase) * 42,
        size.height * .15 + math.cos(phase * .8) * 34,
      ),
      150 + math.sin(phase * 1.3) * 18,
      const Color(0x4D60A5FA),
    );
    _orb(
      canvas,
      Offset(
        size.width * .82 + math.cos(phase * .7) * 54,
        size.height * .26 + math.sin(phase) * 48,
      ),
      128 + math.cos(phase) * 16,
      const Color(0x42F472B6),
    );
    _orb(
      canvas,
      Offset(
        size.width * .68 + math.sin(phase * .55) * 64,
        size.height * .82 + math.cos(phase * .9) * 52,
      ),
      190 + math.sin(phase * .75) * 24,
      const Color(0x4FA78BFA),
    );

    for (var i = 0; i < 18; i++) {
      final angle = phase * (.18 + i * .013) + i * 2.17;
      final x = (size.width * ((i * 37) % 100) / 100 + math.sin(angle) * 24) %
          size.width;
      final y = (size.height * ((i * 61) % 100) / 100 + math.cos(angle) * 18) %
          size.height;
      canvas.drawCircle(
        Offset(x, y),
        1.2 + (i % 3) * .6,
        Paint()..color = const Color(0x42FFFFFF),
      );
    }
  }

  void _orb(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 34),
    );
  }

  @override
  bool shouldRepaint(covariant _GlassMotionPainter oldDelegate) =>
      oldDelegate.t != t;
}
