import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';

/// A view of the existing session ticker. No independent timer or animation.
class FocusTimerDial extends StatelessWidget {
  const FocusTimerDial(
      {super.key,
      required this.session,
      required this.isChinese,
      this.size = 144});
  final FocusSession session;
  final bool isChinese;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<AppVisualThemeMarker>()?.visualTheme ??
            AppVisualTheme.minimalism;
    final tokens = AppVisualTokens.of(theme);
    final status = session.paused
        ? (isChinese ? '已暂停' : 'Paused')
        : session.active
            ? (isChinese ? '计时中' : 'Running')
            : session.stageName == 'finished'
                ? (isChinese ? '已结束' : 'Finished')
                : (isChinese ? '待开始' : 'Ready');
    final elapsed = math.max(0, session.elapsedSeconds);
    final total = session.plannedMinutes > 0
        ? session.plannedMinutes * 60
        : elapsed + math.max(0, session.remainingSeconds);
    final progress = total > 0 ? elapsed / total : 0.0;
    return Semantics(
      label: isChinese
          ? '专注表盘，已用${session.elapsedLabel}，剩余${session.remainingLabel}，$status'
          : 'Focus dial, ${session.elapsedLabel} elapsed, ${session.remainingLabel} remaining, $status',
      child: ExcludeSemantics(
        child: SizedBox(
            width: size,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                    dimension: size,
                    child: CustomPaint(
                      key: const ValueKey('focus-timer-dial-face'),
                      painter: FocusTimerDialPainter(
                          elapsedSeconds: elapsed,
                          progress: progress.clamp(0.0, 1.0),
                          ink: tokens.ink,
                          accent: tokens.accent,
                          surface: tokens.panel,
                          line: tokens.line,
                          fontFamily:
                              Theme.of(context).textTheme.bodySmall?.fontFamily,
                          paused: session.paused),
                    )),
                const SizedBox(height: 6),
                Text(
                    session.paused || !session.active
                        ? status
                        : '${isChinese ? '已用' : 'Elapsed'} ${session.elapsedLabel}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: tokens.muted,
                        fontSize: 11,
                        fontFeatures: const [FontFeature.tabularFigures()])),
              ],
            )),
      ),
    );
  }
}

class FocusTimerDialPainter extends CustomPainter {
  const FocusTimerDialPainter(
      {required this.elapsedSeconds,
      required this.progress,
      required this.ink,
      required this.accent,
      required this.surface,
      required this.line,
      this.fontFamily,
      required this.paused});
  final int elapsedSeconds;
  final double progress;
  final Color ink, accent, surface, line;
  final String? fontFamily;
  final bool paused;
  double get secondAngle =>
      (elapsedSeconds % 60) / 60 * math.pi * 2 - math.pi / 2;
  double get minuteAngle =>
      (elapsedSeconds % 3600) / 3600 * math.pi * 2 - math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(center, radius - 1, Paint()..color = surface);
    canvas.drawCircle(
        center,
        radius - 2,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    final ring = Rect.fromCircle(center: center, radius: radius - 3);
    canvas.drawArc(
        ring,
        -math.pi / 2,
        progress * math.pi * 2,
        false,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
    Offset point(double angle, double distance) =>
        center + Offset(math.cos(angle) * distance, math.sin(angle) * distance);
    for (var i = 0; i < 60; i++) {
      final major = i % 5 == 0;
      final angle = i / 60 * math.pi * 2 - math.pi / 2;
      canvas.drawLine(
          point(angle, radius * (major ? .76 : .81)),
          point(angle, radius * .86),
          Paint()
            ..color = major ? ink : line
            ..strokeWidth = major ? 1.6 : 1);
    }
    for (final mark in [0, 15, 30, 45]) {
      final painter = TextPainter(
          text: TextSpan(
              text: '$mark',
              style: TextStyle(
                  color: ink.withValues(alpha: .65),
                  fontSize: radius * .15,
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.w500)),
          textDirection: TextDirection.ltr)
        ..layout();
      painter.paint(
          canvas,
          point(mark / 60 * math.pi * 2 - math.pi / 2, radius * .61) -
              Offset(painter.width / 2, painter.height / 2));
      painter.dispose();
    }
    canvas.drawLine(
        point(minuteAngle, -radius * .12),
        point(minuteAngle, radius * .46),
        Paint()
          ..color = ink
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
    canvas.drawLine(
        point(secondAngle, -radius * .18),
        point(secondAngle, radius * .72),
        Paint()
          ..color = accent
          ..strokeWidth = 1.7
          ..strokeCap = StrokeCap.round);
    canvas.drawCircle(center, radius * .045, Paint()..color = accent);
    if (paused) {
      for (final dx in [-3.0, 3.0]) {
        canvas.drawLine(
            center + Offset(dx, radius * .22),
            center + Offset(dx, radius * .34),
            Paint()
              ..color = ink
              ..strokeWidth = 2
              ..strokeCap = StrokeCap.round);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FocusTimerDialPainter oldDelegate) =>
      elapsedSeconds != oldDelegate.elapsedSeconds ||
      progress != oldDelegate.progress ||
      paused != oldDelegate.paused ||
      ink != oldDelegate.ink ||
      accent != oldDelegate.accent ||
      surface != oldDelegate.surface ||
      line != oldDelegate.line ||
      fontFamily != oldDelegate.fontFamily;
}
