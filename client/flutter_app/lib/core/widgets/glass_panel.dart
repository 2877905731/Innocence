import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
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
    final visualTheme =
        Theme.of(context).extension<AppVisualThemeMarker>()?.visualTheme;
    if (visualTheme != null) {
      return _ThemeAwarePanel(
        visualTheme: visualTheme,
        padding: padding,
        child: child,
      );
    }

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

class _ThemeAwarePanel extends StatefulWidget {
  const _ThemeAwarePanel({
    required this.visualTheme,
    required this.padding,
    required this.child,
  });

  final AppVisualTheme visualTheme;
  final EdgeInsets padding;
  final Widget child;

  @override
  State<_ThemeAwarePanel> createState() => _ThemeAwarePanelState();
}

class _ThemeAwarePanelState extends State<_ThemeAwarePanel> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = AppVisualTokens.of(widget.visualTheme);
    final glass = widget.visualTheme == AppVisualTheme.glass;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final radius = switch (widget.visualTheme) {
      AppVisualTheme.minimalism || AppVisualTheme.wabiSabi => 0.0,
      AppVisualTheme.midCentury => 18.0,
      AppVisualTheme.glass => 22.0,
    };
    final decoration = switch (widget.visualTheme) {
      AppVisualTheme.minimalism => BoxDecoration(
          color: tokens.panel,
          border: Border(top: BorderSide(color: tokens.ink, width: 2)),
        ),
      AppVisualTheme.wabiSabi => BoxDecoration(color: tokens.panel),
      AppVisualTheme.midCentury => BoxDecoration(
          color: tokens.panel,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(28),
            bottomLeft: Radius.circular(8),
          ),
          border: Border(left: BorderSide(color: tokens.accent, width: 4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F2C2416),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
      AppVisualTheme.glass => BoxDecoration(
          color: _hovered ? const Color(0x52172A55) : const Color(0x3D101D3B),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: _hovered ? const Color(0x78FFFFFF) : const Color(0x48FFFFFF),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  _hovered ? const Color(0x665F8CFF) : const Color(0x351F2687),
              blurRadius: _hovered ? 44 : 28,
              spreadRadius: -5,
              offset: Offset(0, _hovered ? 16 : 10),
            ),
          ],
        ),
    };

    final content = glass
        ? ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _hovered ? 24 : 18,
                sigmaY: _hovered ? 24 : 18,
              ),
              child: Padding(padding: widget.padding, child: widget.child),
            ),
          )
        : Padding(padding: widget.padding, child: widget.child);

    return MouseRegion(
      onEnter: glass ? (_) => setState(() => _hovered = true) : null,
      onExit: glass ? (_) => setState(() => _hovered = false) : null,
      child: AnimatedContainer(
        key: ValueKey(widget.visualTheme),
        duration:
            reduceMotion ? Duration.zero : const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          glass && _hovered && !reduceMotion ? -4 : 0,
          0,
        ),
        decoration: decoration,
        child: content,
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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x40171C22),
                Color(0x3410151B),
                Color(0x4811161D),
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
              const BoxShadow(
                color: Color(0x22DCE6F2),
                blurRadius: 18,
                spreadRadius: -12,
                offset: Offset(12, -8),
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
              const Positioned(
                top: -40,
                right: -18,
                child: IgnorePointer(
                  child: _GlassGlow(
                    width: 196,
                    height: 124,
                    colors: [
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
