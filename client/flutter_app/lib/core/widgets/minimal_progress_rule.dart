import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';

/// A measured progress line; the ticks reflect the same actual completion ratio.
class MinimalProgressRule extends StatelessWidget {
  const MinimalProgressRule({super.key, required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final tokens = AppVisualTokens.of(AppVisualTheme.minimalism);
    final progress = value.clamp(0.0, 1.0);
    return Semantics(
      value: '${(progress * 100).round()}%',
      child: SizedBox(
        height: 12,
        width: double.infinity,
        child: CustomPaint(
            painter: _ProgressRulePainter(progress, tokens.ink, tokens.line)),
      ),
    );
  }
}

class _ProgressRulePainter extends CustomPainter {
  const _ProgressRulePainter(this.progress, this.ink, this.line);
  final double progress;
  final Color ink, line;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 2;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint..color = line);
    if (progress > 0) {
      canvas.drawLine(
          Offset.zero, Offset(size.width * progress, 0), paint..color = ink);
    }
    paint.strokeWidth = 1;
    for (var i = 0; i <= 20; i++) {
      final fraction = i / 20;
      final x = (size.width - 1) * fraction + .5;
      canvas.drawLine(Offset(x, 5), Offset(x, i % 5 == 0 ? 12 : 9),
          paint..color = progress > 0 && fraction <= progress ? ink : line);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRulePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      ink != oldDelegate.ink ||
      line != oldDelegate.line;
}
