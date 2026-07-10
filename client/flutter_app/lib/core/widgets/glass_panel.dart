import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';

import '../theme/app_colors.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.desktopTransparent = false,
    this.lightStyle = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool desktopTransparent;
  final bool lightStyle;

  @override
  Widget build(BuildContext context) {
    if (lightStyle) {
      return Container(
        padding: padding,
        decoration: SurfacePalette.cardDecoration(),
        child: child,
      );
    }

    final useDesktopGlass =
        desktopTransparent || AppConfig.deviceType == 'windows';
    if (useDesktopGlass) {
      return _DesktopGlassPanel(
        padding: padding,
        child: child,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 24,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DesktopGlassPanel extends StatelessWidget {
  const _DesktopGlassPanel({
    required this.child,
    required this.padding,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    const radius = 36.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0x40171C22),
                const Color(0x3410151B),
                const Color(0x4811161D),
              ],
            ),
            border: Border.all(
              color: const Color(0x7CCFD9E5),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.06),
                blurRadius: 18,
                spreadRadius: -10,
                offset: const Offset(-4, -4),
              ),
              BoxShadow(
                color: const Color(0x22DCE6F2),
                blurRadius: 18,
                spreadRadius: -12,
                offset: const Offset(12, -8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.10),
                          Colors.white.withValues(alpha: 0.022),
                          Colors.black.withValues(alpha: 0.10),
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -40,
                right: -18,
                child: IgnorePointer(
                  child: _GlassGlow(
                    width: 196,
                    height: 124,
                    colors: const [
                      Color(0x38E2EAF4),
                      Color(0x00E2EAF4),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: -34,
                top: -22,
                child: IgnorePointer(
                  child: _GlassGlow(
                    width: 176,
                    height: 112,
                    colors: [
                      Colors.white.withValues(alpha: 0.14),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.05,
                    child: CustomPaint(
                      painter: _GlassNoisePainter(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassNoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.10);

    const step = 14.0;
    for (double y = 6; y < size.height; y += step) {
      for (double x = 6; x < size.width; x += step) {
        final radius = ((x + y) % 28 == 0) ? 0.75 : 0.45;
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlassGlow extends StatelessWidget {
  const _GlassGlow({
    required this.width,
    required this.height,
    required this.colors,
  });

  final double width;
  final double height;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: RadialGradient(colors: colors),
          ),
        ),
      ),
    );
  }
}
