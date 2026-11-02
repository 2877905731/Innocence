import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';

/// Original vector lettering, independent of platform fonts and language.
/// Only this decorative mark scales; the surrounding page reflows normally.
class ThemeBrandWordmark extends StatelessWidget {
  const ThemeBrandWordmark({super.key, required this.theme});
  final AppVisualTheme theme;

  @override
  Widget build(BuildContext context) => Semantics(
      container: true,
      header: true,
      label: 'Innocence',
      child: ExcludeSemantics(
          child: AspectRatio(
              aspectRatio: theme == AppVisualTheme.midCentury ? 2.65 : 3.8,
              child: CustomPaint(painter: _BrandPainter(theme)))));
}

class _BrandPainter extends CustomPainter {
  const _BrandPainter(this.theme);
  final AppVisualTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final design = theme == AppVisualTheme.midCentury
        ? const Size(620, 234)
        : const Size(680, 179);
    final scale =
        math.min(size.width / design.width, size.height / design.height);
    canvas.save();
    canvas.translate((size.width - design.width * scale) / 2,
        (size.height - design.height * scale) / 2);
    canvas.scale(scale);
    switch (theme) {
      case AppVisualTheme.wabiSabi:
        _paintInk(canvas);
      case AppVisualTheme.midCentury:
        _paintModern(canvas);
      case AppVisualTheme.glass:
        _paintGlass(canvas);
      case AppVisualTheme.minimalism:
        break;
    }
    canvas.restore();
  }

  static Path _handLetter(String letter) => switch (letter) {
        'I' => Path()
          ..moveTo(7, 17)
          ..cubicTo(22, 13, 47, 14, 58, 10)
          ..moveTo(35, 14)
          ..cubicTo(31, 41, 33, 75, 27, 111)
          ..moveTo(4, 115)
          ..cubicTo(20, 109, 42, 112, 54, 107),
        'n' => Path()
          ..moveTo(9, 54)
          ..cubicTo(12, 70, 7, 98, 7, 110)
          ..moveTo(10, 78)
          ..cubicTo(24, 37, 57, 39, 55, 70)
          ..cubicTo(54, 85, 52, 102, 57, 108),
        'o' => Path()
          ..moveTo(48, 56)
          ..cubicTo(12, 30, -4, 90, 15, 105)
          ..cubicTo(41, 127, 68, 72, 47, 54),
        'c' => Path()
          ..moveTo(53, 58)
          ..cubicTo(20, 27, -3, 79, 12, 101)
          ..cubicTo(24, 116, 43, 110, 54, 96),
        'e' => Path()
          ..moveTo(9, 79)
          ..cubicTo(30, 83, 62, 65, 47, 53)
          ..cubicTo(26, 36, 0, 62, 8, 93)
          ..cubicTo(13, 116, 40, 115, 56, 98),
        _ => Path(),
      };

  void _paintInk(Canvas canvas) {
    const ink = Color(0xFF403D34);
    final pen = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    const word = 'Innocence';
    var x = 12.0;
    for (var i = 0; i < word.length; i++) {
      canvas.save();
      canvas.translate(x, 13 + (i.isEven ? 1.0 : -2.0));
      canvas.rotate(i.isEven ? -.018 : .012);
      canvas.drawPath(_handLetter(word[i]), pen);
      // Vary downstroke weight while keeping the connecting curves light.
      if (word[i] == 'I') {
        canvas.drawPath(
            Path()
              ..moveTo(32, 17)
              ..cubicTo(27, 50, 29, 87, 25, 111)
              ..lineTo(31, 110)
              ..cubicTo(35, 78, 34, 44, 37, 15)
              ..close(),
            Paint()..color = ink);
      } else if (word[i] == 'n') {
        canvas.drawPath(
            Path()
              ..moveTo(8, 55)
              ..lineTo(5, 109)
              ..lineTo(10, 109)
              ..lineTo(13, 59)
              ..close(),
            Paint()..color = ink);
      }
      canvas.restore();
      x += word[i] == 'I' ? 70 : 69;
    }
    canvas.drawPath(
        Path()
          ..moveTo(21, 153)
          ..cubicTo(146, 146, 309, 161, 522, 148),
        Paint()
          ..color = ink.withValues(alpha: .38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .9);
    canvas.save();
    canvas.translate(646, 112);
    canvas.rotate(-.07);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, 18, 21), const Radius.circular(2)),
        Paint()..color = const Color(0xFFA56851));
    final seal = Paint()
      ..color = const Color(0xFFF0EADD)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(5, 6), const Offset(13, 15), seal);
    canvas.drawLine(const Offset(12, 5), const Offset(6, 16), seal);
    canvas.restore();
  }

  static Path _geometricLetter(String letter) => switch (letter) {
        'I' => Path()
          ..moveTo(32, 8)
          ..lineTo(32, 94),
        'N' => Path()
          ..moveTo(7, 94)
          ..lineTo(7, 8)
          ..lineTo(65, 94)
          ..lineTo(65, 8),
        'O' => Path()
          ..addRRect(RRect.fromRectAndRadius(
              const Rect.fromLTWH(4, 8, 66, 86), const Radius.circular(33))),
        'C' => Path()
          ..moveTo(65, 19)
          ..cubicTo(26, -15, -15, 29, 7, 76)
          ..cubicTo(21, 104, 49, 100, 66, 85),
        'E' => Path()
          ..moveTo(65, 8)
          ..lineTo(7, 8)
          ..lineTo(7, 94)
          ..lineTo(65, 94)
          ..moveTo(7, 50)
          ..lineTo(54, 50),
        _ => Path(),
      };

  static Path _line(String text, double x, double y, double advance) {
    final result = Path();
    for (var i = 0; i < text.length; i++) {
      result.addPath(_geometricLetter(text[i]), Offset(x + i * advance, y));
    }
    return result;
  }

  void _paintModern(Canvas canvas) {
    final letters = Path()
      ..addPath(_line('INNO', 11, 5, 99), Offset.zero)
      ..addPath(_line('CENCE', 18, 122, 99), Offset.zero);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.square;
    canvas.drawPath(letters.shift(const Offset(7, 6)),
        stroke..color = const Color(0xFFE0B949));
    canvas.drawPath(letters, stroke..color = const Color(0xFF2F514C));
    final star = Path();
    const center = Offset(539, 53);
    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi / 8 - math.pi / 2;
      final radius = i.isEven ? 36.0 : 10.0;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (i == 0) {
        star.moveTo(point.dx, point.dy);
      } else {
        star.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(star..close(), Paint()..color = const Color(0xFFBD603D));
    canvas.drawLine(
        const Offset(536, 114),
        const Offset(604, 114),
        Paint()
          ..color = const Color(0xFF2F514C)
          ..strokeWidth = 2);
  }

  void _paintGlass(Canvas canvas) {
    final letters = _line('INNOCENCE', 8, 25, 75);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(letters.shift(const Offset(2.5, 3.5)),
        stroke..color = const Color(0xFF86A7F5).withValues(alpha: .35));
    canvas.drawPath(
        letters,
        stroke
          ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF5FBFF),
                Color(0xFFB7C8E9),
                Color(0xFF8496B9),
                Color(0xFFEDF5FF)
              ],
              stops: [
                0,
                .39,
                .58,
                1
              ]).createShader(const Rect.fromLTWH(0, 30, 680, 100)));
    canvas.drawPath(
        letters.shift(const Offset(-1.4, -1.6)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 1.1
          ..color = Colors.white.withValues(alpha: .85));
    canvas.drawPath(
        Path()
          ..moveTo(12, 153)
          ..cubicTo(208, 132, 457, 172, 665, 146),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..shader = const LinearGradient(colors: [
            Color(0x0089B8FF),
            Color(0xFFBAD9FF),
            Color(0x0089B8FF)
          ]).createShader(const Rect.fromLTWH(12, 140, 653, 20)));
  }

  @override
  bool shouldRepaint(_BrandPainter oldDelegate) => oldDelegate.theme != theme;
}
