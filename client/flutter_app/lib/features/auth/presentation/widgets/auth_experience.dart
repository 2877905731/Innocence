import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/widgets/desktop_close_button.dart';
import 'package:innocence_flutter/core/widgets/desktop_drag_region.dart';

class AuthExperience extends StatelessWidget {
  const AuthExperience({
    super.key,
    required this.language,
    required this.visualTheme,
    required this.onThemeChanged,
    required this.stageNumber,
    required this.title,
    required this.description,
    required this.child,
  });

  final AppLanguage language;
  final AppVisualTheme visualTheme;
  final ValueChanged<AppVisualTheme> onThemeChanged;
  final String stageNumber;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = AppVisualTokens.of(visualTheme);
    final isWindows = AppConfig.deviceType == 'windows';

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _AuthArtworkPainter(
                theme: visualTheme,
                tokens: tokens,
              ),
            ),
          ),
          if (isWindows)
            const Positioned(
              top: 0,
              left: 0,
              right: 104,
              height: 44,
              child: DesktopDragRegion(),
            ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final split = constraints.maxWidth >= 760;
                final horizontal = split ? 46.0 : 22.0;
                final top = isWindows ? 62.0 : 28.0;
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(0, constraints.maxHeight - top - 28),
                    ),
                    child: split
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 9,
                                child: _EditorialSide(
                                  language: language,
                                  visualTheme: visualTheme,
                                  tokens: tokens,
                                  stageNumber: stageNumber,
                                ),
                              ),
                              const SizedBox(width: 52),
                              Expanded(
                                flex: 11,
                                child: _FunctionalSide(
                                  language: language,
                                  visualTheme: visualTheme,
                                  onThemeChanged: onThemeChanged,
                                  tokens: tokens,
                                  title: title,
                                  description: description,
                                  child: child,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _EditorialSide(
                                language: language,
                                visualTheme: visualTheme,
                                tokens: tokens,
                                stageNumber: stageNumber,
                                compact: true,
                              ),
                              const SizedBox(height: 32),
                              _FunctionalSide(
                                language: language,
                                visualTheme: visualTheme,
                                onThemeChanged: onThemeChanged,
                                tokens: tokens,
                                title: title,
                                description: description,
                                child: child,
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
          if (isWindows)
            const Positioned(
              top: 12,
              right: 12,
              child: DesktopWindowControls(compact: true),
            ),
        ],
      ),
    );
  }
}

class _EditorialSide extends StatelessWidget {
  const _EditorialSide({
    required this.language,
    required this.visualTheme,
    required this.tokens,
    required this.stageNumber,
    this.compact = false,
  });

  final AppLanguage language;
  final AppVisualTheme visualTheme;
  final AppVisualTokens tokens;
  final String stageNumber;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isChinese = language.isChinese;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 32, height: 3, color: tokens.accent),
            const SizedBox(width: 10),
            Text(
              'INN / $stageNumber',
              style: TextStyle(
                color: tokens.ink,
                fontSize: 11,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 26 : 58),
        _ThemeBrandTitle(
          theme: visualTheme,
          tokens: tokens,
          compact: compact,
        ),
        const SizedBox(height: 24),
        Container(
          width: compact ? double.infinity : 260,
          padding: const EdgeInsets.only(top: 14),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: tokens.line)),
          ),
          child: Text(
            isChinese
                ? '把喧嚣放在门外。\n让今天，只围绕真正重要的事。'
                : 'Leave the noise at the door.\nLet today orbit what matters.',
            style: TextStyle(
              color: tokens.muted,
              fontSize: 13,
              height: 1.65,
              letterSpacing: 0.15,
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 80),
          Text(
            visualTheme.label(isChinese: isChinese).toUpperCase(),
            style: TextStyle(
              color: tokens.muted,
              fontSize: 10,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _ThemeBrandTitle extends StatelessWidget {
  const _ThemeBrandTitle({
    required this.theme,
    required this.tokens,
    required this.compact,
  });

  final AppVisualTheme theme;
  final AppVisualTokens tokens;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 300.0 : 330.0;
    final height = compact ? 112.0 : 154.0;
    return SizedBox(
      width: width,
      height: height,
      child: switch (theme) {
        AppVisualTheme.minimalism => _minimalistMark(),
        AppVisualTheme.wabiSabi => _wabiSabiMark(),
        AppVisualTheme.midCentury => _midCenturyMark(),
        AppVisualTheme.glass => _glassMark(),
      },
    );
  }

  Widget _minimalistMark() {
    final size = compact ? 52.0 : 76.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Text(
          compact ? 'INNO\nCENCE' : 'INNO\n—CENCE',
          style: TextStyle(
            color: tokens.ink,
            fontSize: size,
            height: 0.82,
            letterSpacing: compact ? -2.8 : -5.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        Positioned(
          left: compact ? 120 : 176,
          top: compact ? 8 : 11,
          child: Container(
            width: compact ? 9 : 11,
            height: compact ? 9 : 11,
            color: tokens.accent,
          ),
        ),
        Positioned(
          left: compact ? 210 : 271,
          top: compact ? 77 : 112,
          child: Transform.rotate(
            angle: -0.12,
            child: Container(width: 52, height: 3, color: tokens.accent),
          ),
        ),
      ],
    );
  }

  Widget _wabiSabiMark() {
    final large = compact ? 55.0 : 78.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: compact ? 12 : 18,
          top: 0,
          child: Text(
            'Inno',
            style: TextStyle(
              color: tokens.ink,
              fontFamily: 'Georgia',
              fontSize: large,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              height: 0.92,
              letterSpacing: -3,
            ),
          ),
        ),
        Positioned(
          left: compact ? 72 : 98,
          top: compact ? 49 : 69,
          child: Text(
            'cence',
            style: TextStyle(
              color: tokens.artOne,
              fontFamily: 'Georgia',
              fontSize: compact ? 49 : 70,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              height: 0.92,
              letterSpacing: -2.2,
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: compact ? 58 : 84,
          child: Container(
            width: compact ? 30 : 38,
            height: compact ? 30 : 38,
            alignment: Alignment.center,
            color: tokens.accent,
            child: Text(
              '静',
              style: TextStyle(
                color: tokens.onAccent,
                fontFamily: 'serif',
                fontSize: compact ? 16 : 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Positioned(
          right: compact ? 7 : 0,
          top: 8,
          child: Text(
            '一\n息\n一\n念',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.muted,
              fontFamily: 'serif',
              fontSize: compact ? 9 : 10,
              height: 1.35,
              letterSpacing: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _midCenturyMark() {
    final topSize = compact ? 40.0 : 54.0;
    final bottomSize = compact ? 38.0 : 52.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: 4,
          child: Transform.rotate(
            angle: -0.035,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                compact ? 12 : 16,
                compact ? 4 : 6,
                compact ? 14 : 18,
                compact ? 6 : 8,
              ),
              color: tokens.artOne,
              child: Text(
                'INNO',
                style: TextStyle(
                  color: const Color(0xFFFFF3D8),
                  fontSize: topSize,
                  height: 0.9,
                  letterSpacing: -2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: compact ? 54 : 72,
          top: compact ? 51 : 69,
          child: Transform.rotate(
            angle: 0.028,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                compact ? 12 : 16,
                compact ? 5 : 7,
                compact ? 15 : 20,
                compact ? 7 : 9,
              ),
              color: tokens.accent,
              child: Text(
                'CENCE',
                style: TextStyle(
                  color: tokens.onAccent,
                  fontSize: bottomSize,
                  height: 0.88,
                  letterSpacing: -2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: compact ? 232 : 286,
          top: compact ? 4 : 7,
          child: Container(
            width: compact ? 44 : 55,
            height: compact ? 44 : 55,
            decoration: BoxDecoration(
              color: tokens.artTwo,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '✶',
              style: TextStyle(
                color: tokens.ink,
                fontSize: compact ? 24 : 30,
                height: 1,
              ),
            ),
          ),
        ),
        Positioned(
          left: compact ? 12 : 18,
          top: compact ? 91 : 126,
          child: Container(
            width: compact ? 52 : 70,
            height: compact ? 12 : 16,
            color: const Color(0xFF7180B5),
          ),
        ),
      ],
    );
  }

  Widget _glassMark() {
    final size = compact ? 51.0 : 70.0;
    final baseStyle = TextStyle(
      fontSize: size,
      height: 0.84,
      letterSpacing: compact ? -2.4 : -4,
      fontWeight: FontWeight.w800,
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 8,
          top: 8,
          child: Text(
            'INNO\nCENCE',
            style: baseStyle.copyWith(
              color: tokens.artTwo.withValues(alpha: 0.5),
              shadows: [
                Shadow(
                  color: tokens.artTwo.withValues(alpha: 0.55),
                  blurRadius: 24,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: Text(
            'INNO\nCENCE',
            style: baseStyle.copyWith(
              color: tokens.ink,
              shadows: [
                Shadow(
                  color: tokens.artOne.withValues(alpha: 0.75),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: compact ? 170 : 230,
          top: compact ? 70 : 100,
          child: Transform.rotate(
            angle: -0.16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: tokens.accent.withValues(alpha: 0.14),
                border:
                    Border.all(color: tokens.accent.withValues(alpha: 0.65)),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'FOCUS / 01',
                style: TextStyle(
                  color: tokens.accent,
                  fontSize: 8,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FunctionalSide extends StatelessWidget {
  const _FunctionalSide({
    required this.language,
    required this.visualTheme,
    required this.onThemeChanged,
    required this.tokens,
    required this.title,
    required this.description,
    required this.child,
  });

  final AppLanguage language;
  final AppVisualTheme visualTheme;
  final ValueChanged<AppVisualTheme> onThemeChanged;
  final AppVisualTokens tokens;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 30),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border.all(color: tokens.line),
        borderRadius: BorderRadius.circular(tokens.isGlass ? 24 : 6),
        boxShadow: tokens.isGlass
            ? const [
                BoxShadow(
                  color: Color(0x59000000),
                  blurRadius: 50,
                  offset: Offset(0, 22),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthThemeSwitcher(
            language: language,
            visualTheme: visualTheme,
            onThemeChanged: onThemeChanged,
          ),
          const SizedBox(height: 34),
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 9),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}

class AuthThemeSwitcher extends StatelessWidget {
  const AuthThemeSwitcher({
    super.key,
    required this.language,
    required this.visualTheme,
    required this.onThemeChanged,
  });

  final AppLanguage language;
  final AppVisualTheme visualTheme;
  final ValueChanged<AppVisualTheme> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final currentTokens = AppVisualTokens.of(visualTheme);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          language.isChinese ? '视觉' : 'LOOK',
          style: TextStyle(
            color: currentTokens.muted,
            fontSize: 10,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        ...AppVisualTheme.values.map((theme) {
          final tokens = AppVisualTokens.of(theme);
          final selected = theme == visualTheme;
          return Tooltip(
            message: theme.label(isChinese: language.isChinese),
            child: Semantics(
              label: theme.label(isChinese: language.isChinese),
              selected: selected,
              button: true,
              child: InkWell(
                key: ValueKey('visual-theme-${theme.storageValue}'),
                onTap: () => onThemeChanged(theme),
                borderRadius: BorderRadius.circular(99),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? 34 : 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: tokens.canvas,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          selected ? currentTokens.accent : currentTokens.line,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: tokens.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _AuthArtworkPainter extends CustomPainter {
  const _AuthArtworkPainter({required this.theme, required this.tokens});

  final AppVisualTheme theme;
  final AppVisualTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = tokens.line
          .withValues(alpha: theme == AppVisualTheme.glass ? 0.28 : 0.48)
      ..strokeWidth = 1;
    const spacing = 72.0;
    for (double x = 24; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    final artPaint = Paint()..style = PaintingStyle.fill;
    switch (theme) {
      case AppVisualTheme.minimalism:
        artPaint.color = tokens.artTwo;
        canvas.drawCircle(
            Offset(size.width * 0.12, size.height * 0.84), 88, artPaint);
        artPaint
          ..color = tokens.artOne
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawArc(
          Rect.fromCircle(
              center: Offset(size.width * 0.18, size.height * 0.8),
              radius: 124),
          -1.3,
          2.2,
          false,
          artPaint,
        );
        artPaint
          ..style = PaintingStyle.fill
          ..color = tokens.accent;
        canvas.drawRect(
          Rect.fromLTWH(size.width * 0.055, size.height * 0.735, 10, 10),
          artPaint,
        );
      case AppVisualTheme.wabiSabi:
        final ensoCenter = Offset(size.width * 0.14, size.height * 0.82);
        artPaint
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 18
          ..color = tokens.artOne.withValues(alpha: 0.22);
        canvas.drawArc(
          Rect.fromCircle(center: ensoCenter, radius: 104),
          -0.65,
          math.pi * 1.63,
          false,
          artPaint,
        );
        artPaint
          ..color = tokens.artOne.withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4;
        canvas.drawArc(
          Rect.fromCircle(center: ensoCenter, radius: 91),
          -0.48,
          math.pi * 1.54,
          false,
          artPaint,
        );
        artPaint
          ..strokeWidth = 5
          ..color = tokens.artOne.withValues(alpha: 0.36);
        canvas.drawLine(
          Offset(size.width * 0.035, size.height * 0.93),
          Offset(size.width * 0.27, size.height * 0.68),
          artPaint,
        );
        artPaint
          ..strokeWidth = 2
          ..color = tokens.muted.withValues(alpha: 0.24);
        for (var i = 0; i < 5; i++) {
          canvas.drawLine(
            Offset(size.width * 0.03, size.height * (0.73 + i * 0.026)),
            Offset(size.width * (0.075 + i * 0.012),
                size.height * (0.72 + i * 0.026)),
            artPaint,
          );
        }
        artPaint
          ..style = PaintingStyle.fill
          ..color = tokens.accent.withValues(alpha: 0.82);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(size.width * 0.285, size.height * 0.91),
            width: 34,
            height: 34,
          ),
          artPaint,
        );
      case AppVisualTheme.midCentury:
        final collageX = size.width * 0.025;
        final collageY = size.height * 0.68;
        canvas.save();
        canvas.translate(collageX + 58, collageY + 88);
        canvas.rotate(-0.11);
        artPaint
          ..style = PaintingStyle.fill
          ..color = tokens.ink;
        canvas.drawRect(const Rect.fromLTWH(-58, -88, 116, 176), artPaint);
        canvas.restore();

        artPaint.color = const Color(0xFF7180B5);
        canvas.drawRect(
          Rect.fromLTWH(collageX + 72, collageY - 6, 68, 176),
          artPaint,
        );
        artPaint.color = tokens.artTwo;
        canvas.drawCircle(Offset(collageX + 151, collageY + 34), 64, artPaint);
        artPaint.color = tokens.artOne;
        final wedge = Path()
          ..moveTo(collageX + 116, collageY + 86)
          ..lineTo(collageX + 266, collageY + 148)
          ..lineTo(collageX + 188, collageY + 220)
          ..close();
        canvas.drawPath(wedge, artPaint);
        artPaint.color = tokens.accent;
        canvas.drawArc(
          Rect.fromLTWH(collageX + 8, collageY + 118, 142, 142),
          math.pi,
          math.pi,
          true,
          artPaint,
        );
        artPaint.color = tokens.canvas;
        canvas.drawCircle(Offset(collageX + 79, collageY + 189), 32, artPaint);
        artPaint.color = const Color(0xFF6E4B3A);
        canvas.drawRect(
          Rect.fromLTWH(collageX + 198, collageY + 26, 42, 128),
          artPaint,
        );
        _drawStarburst(
          canvas,
          center: Offset(collageX + 250, collageY + 4),
          color: tokens.accent,
          innerRadius: 6,
          outerRadius: 34,
          rays: 14,
        );
        artPaint.color = tokens.ink;
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(collageX + 260 + i * 18, collageY + 76),
            4,
            artPaint,
          );
        }
      case AppVisualTheme.glass:
        artPaint
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 52)
          ..color = tokens.artOne.withValues(alpha: 0.34);
        canvas.drawCircle(
            Offset(size.width * 0.08, size.height * 0.86), 180, artPaint);
        artPaint.color = tokens.artTwo.withValues(alpha: 0.28);
        canvas.drawCircle(
            Offset(size.width * 0.91, size.height * 0.13), 190, artPaint);
        artPaint
          ..maskFilter = null
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = tokens.artOne.withValues(alpha: 0.58);
        final orbitCenter = Offset(size.width * 0.145, size.height * 0.82);
        canvas.save();
        canvas.translate(orbitCenter.dx, orbitCenter.dy);
        canvas.rotate(-0.34);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 276, height: 116),
          artPaint,
        );
        artPaint.color = tokens.artTwo.withValues(alpha: 0.42);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 210, height: 210),
          artPaint,
        );
        canvas.restore();
        artPaint
          ..style = PaintingStyle.fill
          ..color = tokens.accent;
        canvas.drawCircle(
          Offset(orbitCenter.dx + 112, orbitCenter.dy - 49),
          7,
          artPaint,
        );
        final particlePaint = Paint()
          ..color = tokens.ink.withValues(alpha: 0.5);
        for (var i = 0; i < 9; i++) {
          final angle = i * 0.78;
          canvas.drawCircle(
            Offset(
              orbitCenter.dx + math.cos(angle) * (64 + (i % 3) * 24),
              orbitCenter.dy + math.sin(angle) * (48 + (i % 2) * 18),
            ),
            i.isEven ? 2.2 : 1.4,
            particlePaint,
          );
        }
    }
  }

  void _drawStarburst(
    Canvas canvas, {
    required Offset center,
    required Color color,
    required double innerRadius,
    required double outerRadius,
    required int rays,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < rays; i++) {
      final angle = math.pi * 2 * i / rays;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * innerRadius,
        center + Offset(math.cos(angle), math.sin(angle)) * outerRadius,
        paint,
      );
    }
    canvas.drawCircle(center, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _AuthArtworkPainter oldDelegate) {
    return oldDelegate.theme != theme;
  }
}
