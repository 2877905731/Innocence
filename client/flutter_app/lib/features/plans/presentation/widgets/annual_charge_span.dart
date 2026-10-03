import 'dart:math';
import 'package:flutter/material.dart';

class AnnualMonthGrid {
  const AnnualMonthGrid(this.width);

  static const gap = 4.0;
  final double width;

  double get cellWidth => (width - gap * 11) / 12;
  double left(int month) => (month - 1) * (cellWidth + gap);
  double spanWidth(int startMonth, int endMonth) =>
      left(endMonth) + cellWidth - left(startMonth);
}

class AnnualChargeSpan extends StatefulWidget {
  const AnnualChargeSpan({
    super.key,
    required this.trackColor,
    required this.surfaceColor,
    this.glass = false,
    required this.color,
    required this.startMonth,
    required this.endMonth,
    required this.progressPercent,
  });

  final Color trackColor;
  final Color surfaceColor;
  final bool glass;
  final Color color;
  final int startMonth;
  final int endMonth;
  final int progressPercent;

  @override
  State<AnnualChargeSpan> createState() => AnnualChargeSpanState();
}

class AnnualChargeSpanState extends State<AnnualChargeSpan>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.stop();
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
    final start = widget.startMonth.clamp(1, 12);
    final end = widget.endMonth.clamp(start, 12);
    final glass = widget.glass;
    return LayoutBuilder(
      builder: (context, constraints) {
        final grid = AnnualMonthGrid(constraints.maxWidth);
        final spanWidth = grid.spanWidth(start, end);
        return SizedBox(
          key: ValueKey(
              'annual-month-span-${widget.startMonth}-${widget.endMonth}'),
          height: 28,
          child: Stack(
            children: [
              for (var month = 1; month <= 12; month += 1)
                Positioned(
                  left: grid.left(month),
                  width: grid.cellWidth,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    key: ValueKey('annual-month-track-$month'),
                    decoration: BoxDecoration(
                      color: glass
                          ? const Color(0x55334490)
                          : widget.trackColor.withValues(alpha: 0.55),
                      border: glass
                          ? Border.all(color: const Color(0x38E0E8FF))
                          : null,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              Positioned(
                left: grid.left(start),
                width: spanWidth,
                top: 0,
                bottom: 0,
                child: Stack(
                  key: ValueKey('annual-month-active-$start-$end'),
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: glass
                              ? const Color(0x36243571)
                              : widget.surfaceColor.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                            end: widget.progressPercent.clamp(0, 100) / 100),
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 550),
                        curve: Curves.easeOutCubic,
                        builder: (context, progress, child) => Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            key: ValueKey(
                                'annual-month-charge-fill-$start-$end'),
                            width: spanWidth * progress,
                            height: 28,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) => RepaintBoundary(
                                  child: CustomPaint(
                                    painter: _SeamlessChargePainter(
                                      color: widget.color,
                                      phase: _controller.value,
                                    ),
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border:
                                Border.all(color: widget.color, width: 1.25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeamlessChargePainter extends CustomPainter {
  const _SeamlessChargePainter({required this.color, required this.phase});

  final Color color;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
    );
    final deep = Color.lerp(color, Colors.black, 0.13)!;
    final bright = Color.lerp(color, Colors.white, 0.24)!;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [deep, color, bright, color, deep],
          stops: const [0, 0.25, 0.52, 0.78, 1],
        ).createShader(rect),
    );

    final pulse = 0.13 + 0.045 * sin(2 * pi * phase);
    for (final seed in const [0.05, 0.55]) {
      final x = ((phase + seed) % 1) * size.width;
      for (final offset in [-size.width, 0.0, size.width]) {
        final center = Offset(x + offset, size.height * 0.50);
        final radius = max(42.0, size.width * 0.28);
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..shader = RadialGradient(
              colors: [
                Colors.white.withValues(alpha: pulse),
                Colors.white.withValues(alpha: 0),
              ],
            ).createShader(Rect.fromCircle(center: center, radius: radius)),
        );
      }
    }

    for (var index = 0; index < 18; index += 1) {
      final cycle = index.isEven ? 1 : 2;
      final seed = (index * 0.61803398875) % 1;
      final x = ((seed + phase * cycle) % 1) * size.width;
      final y = 4.5 + (index * 7.1) % max(5.0, size.height - 9);
      final opacity = 0.30 + (index % 4) * 0.12;
      final dotRadius = index % 5 == 0 ? 1.5 : 0.8;
      for (final offset in [-size.width, 0.0, size.width]) {
        canvas.drawCircle(
          Offset(x + offset, y),
          dotRadius,
          Paint()..color = Colors.white.withValues(alpha: opacity),
        );
        if (index % 3 == 0) {
          canvas.drawLine(
            Offset(x + offset - 3, y + 1.2),
            Offset(x + offset + 2, y - 1.2),
            Paint()
              ..color = Colors.white.withValues(alpha: opacity * 0.65)
              ..strokeWidth = 0.9
              ..strokeCap = StrokeCap.round,
          );
        }
      }
    }
    canvas.drawLine(
      const Offset(0, 1),
      Offset(size.width, 1),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SeamlessChargePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.phase != phase;
}
