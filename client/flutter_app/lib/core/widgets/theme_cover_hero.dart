import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/app/wabi_sabi_typography.dart';
import 'glass_panel.dart';

/// Shared cover identity; layout reflows on phones, desktop canvases and tablets.
class ThemeCoverHero extends StatelessWidget {
  const ThemeCoverHero(
      {super.key,
      required this.theme,
      required this.isChinese,
      required this.eyebrow,
      required this.title,
      required this.description,
      required this.indexLabel});

  final AppVisualTheme theme;
  final bool isChinese;
  final String eyebrow, title, description, indexLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = AppVisualTokens.of(theme);
    final glass = theme == AppVisualTheme.glass;
    final wabi = theme == AppVisualTheme.wabiSabi;
    final ink = tokens.ink;
    final label = switch (theme) {
      AppVisualTheme.wabiSabi => 'WABI / SABI',
      AppVisualTheme.midCentury => 'MID-CENTURY / MODERN',
      _ => 'LIQUID / GLASS',
    };
    final headline = switch (theme) {
      AppVisualTheme.wabiSabi => isChinese ? '静处\n生长' : 'Still.\nGrowing.',
      AppVisualTheme.midCentury =>
        isChinese ? '专注此刻\n慢慢成形' : 'Make time.\nMake progress.',
      _ => isChinese ? '让专注\n流动起来' : 'Find your\nflow.',
    };
    final content = LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 640;
      final size = constraints.maxWidth < 360
          ? 40.0
          : wide
              ? 72.0
              : 54.0;
      final typography = TextStyle(
          color: ink,
          fontSize: size,
          height: wabi ? 1.18 : 1.08,
          letterSpacing: wabi ? 2 : -1.5,
          fontWeight: wabi || glass ? FontWeight.w400 : FontWeight.w900,
          fontFamily: wabi ? WabiSabiTypography.latinFamily : null,
          fontFamilyFallback: wabi ? WabiSabiTypography.fallback : null,
          fontStyle: wabi && !isChinese ? FontStyle.italic : FontStyle.normal);
      final heading =
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 16, runSpacing: 8, children: [
          Text('INNOCENCE',
              style: TextStyle(
                  color: ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2)),
          Text('$label  ·  $indexLabel',
              style: TextStyle(
                  color: tokens.muted, fontSize: 10, letterSpacing: 1.5)),
        ]),
        const SizedBox(height: 24),
        Semantics(
            header: true,
            child: Text(headline,
                key: ValueKey('theme-cover-title-${theme.name}'),
                style: typography)),
        const SizedBox(height: 26),
        if (eyebrow != 'INNOCENCE') ...[
          Text(eyebrow,
              style: TextStyle(
                  color: tokens.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1)),
          const SizedBox(height: 10),
        ],
        Text(title,
            style: TextStyle(
                color: ink,
                fontSize: 22,
                height: 1.3,
                fontFamily: wabi ? WabiSabiTypography.latinFamily : null,
                fontFamilyFallback: wabi ? WabiSabiTypography.fallback : null)),
        const SizedBox(height: 10),
        Text(description,
            style: TextStyle(color: tokens.muted, fontSize: 14, height: 1.6)),
      ]);
      return Padding(
          padding: EdgeInsets.all(wide ? 32 : 22),
          child: wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(child: heading),
                  const SizedBox(width: 28),
                  ExcludeSemantics(
                      child: CustomPaint(
                          size: const Size(168, 200),
                          painter:
                              _CoverArt(theme, tokens.accent, tokens.artTwo))),
                ])
              : heading);
    });
    if (glass) {
      return GlassPanel(
          key: const ValueKey('theme-cover-glass'),
          padding: EdgeInsets.zero,
          child: content);
    }
    return Container(
        key: ValueKey('theme-cover-${theme.name}'),
        decoration: BoxDecoration(
            color: tokens.panel,
            borderRadius: wabi
                ? BorderRadius.zero
                : const BorderRadius.only(
                    topRight: Radius.circular(54),
                    bottomLeft: Radius.circular(18))),
        child: content);
  }
}

class _CoverArt extends CustomPainter {
  const _CoverArt(this.theme, this.accent, this.secondary);
  final AppVisualTheme theme;
  final Color accent, secondary;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()..color = accent;
    if (theme == AppVisualTheme.wabiSabi) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCenter(center: center, width: 142, height: 142),
          -.4, math.pi * 1.78, false, paint);
      canvas.drawLine(center + const Offset(-28, 12),
          center + const Offset(28, -12), paint);
    } else if (theme == AppVisualTheme.midCentury) {
      canvas.drawCircle(
          center + const Offset(22, 36), 54, paint..color = secondary);
      final star = Path();
      for (var i = 0; i < 24; i++) {
        final angle = i * math.pi / 12;
        final radius = i.isEven ? 78.0 : 20.0;
        final p = center + Offset(math.cos(angle), math.sin(angle)) * radius;
        if (i == 0) {
          star.moveTo(p.dx, p.dy);
        } else {
          star.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(star..close(), paint..color = accent);
    } else {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      for (var i = 0; i < 5; i++) {
        canvas.drawOval(
            Rect.fromCenter(
                center: center + Offset(i * 6, i * -4),
                width: 132 - i * 10,
                height: 172 - i * 12),
            paint..color = accent.withValues(alpha: .65 - i * .08));
      }
    }
  }

  @override
  bool shouldRepaint(_CoverArt old) =>
      old.theme != theme || old.accent != accent || old.secondary != secondary;
}
