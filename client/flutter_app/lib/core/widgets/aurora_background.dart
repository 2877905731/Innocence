import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({
    super.key,
    required this.child,
    this.transparentOnWindows = false,
    this.lightStyle = false,
  });

  final Widget child;
  final bool transparentOnWindows;
  final bool lightStyle;

  bool get _useTransparentDesktopBackdrop {
    return transparentOnWindows && AppConfig.deviceType == 'windows';
  }

  @override
  Widget build(BuildContext context) {
    if (lightStyle) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: SurfacePalette.canvas,
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -180,
              left: -120,
              child: _GlowOrb(
                size: 320,
                color: Color(0x0B111111),
              ),
            ),
            const Positioned(
              right: -120,
              top: 60,
              child: _GlowOrb(
                size: 260,
                color: Color(0x06000000),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        const Color(0xFFF7F8FA),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      );
    }

    final backgroundDecoration = _useTransparentDesktopBackdrop
        ? const BoxDecoration(
            color: Color(0x0507090C),
          )
        : const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF09111F),
                Color(0xFF10233C),
                Color(0xFF08111D),
              ],
            ),
          );

    return DecoratedBox(
      decoration: backgroundDecoration,
      child: Stack(
        children: [
          const Positioned(
            top: -160,
            left: -120,
            child: _GlowOrb(
              size: 360,
              color: Color(0x12939FAD),
            ),
          ),
          const Positioned(
            top: 110,
            right: -100,
            child: _GlowOrb(
              size: 320,
              color: Color(0x10D6DDE7),
            ),
          ),
          const Positioned(
            bottom: -150,
            left: 140,
            child: _GlowOrb(
              size: 260,
              color: Color(0x12000000),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _useTransparentDesktopBackdrop
                          ? Colors.white.withValues(alpha: 0.012)
                          : Colors.white.withValues(alpha: 0.04),
                      _useTransparentDesktopBackdrop
                          ? const Color(0x02070A0D)
                          : Colors.transparent,
                      _useTransparentDesktopBackdrop
                          ? Colors.black.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.12),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_useTransparentDesktopBackdrop)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _BackdropNoisePainter(),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackdropNoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.010);

    const step = 18.0;
    for (double y = 8; y < size.height; y += step) {
      for (double x = 8; x < size.width; x += step) {
        final radius = ((x + y) % 36 == 0) ? 0.8 : 0.4;
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
