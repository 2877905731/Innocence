import 'package:flutter/material.dart';

/// Editorial geometry, decorative rather than a chart of user data.
class CitrusStepArtwork extends StatelessWidget {
  const CitrusStepArtwork({super.key, this.width = 176, this.height = 146});
  final double width, height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(
            width: width,
            height: height,
            child: const CustomPaint(painter: _StepPainter())),
      );
}

class _StepPainter extends CustomPainter {
  const _StepPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 176, size.height / 146);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, 176, 146), const Radius.circular(14)),
        Paint()..color = const Color(0xFFF7F5F0));
    final rule = Paint()
      ..color = const Color(0xFFE2DED5)
      ..strokeWidth = 1;
    for (var y = 26.0; y <= 122; y += 24) {
      canvas.drawLine(Offset(16, y), Offset(160, y), rule);
    }
    for (var x = 16.0; x <= 160; x += 24) {
      canvas.drawLine(Offset(x, 26), Offset(x, 122), rule);
    }
    final stairs = Path()
      ..moveTo(22, 122)
      ..lineTo(22, 94)
      ..lineTo(54, 94)
      ..lineTo(54, 74)
      ..lineTo(86, 74)
      ..lineTo(86, 54)
      ..lineTo(118, 54)
      ..lineTo(118, 34)
      ..lineTo(150, 34)
      ..lineTo(150, 122)
      ..close();
    canvas.drawPath(stairs, Paint()..color = const Color(0xFFED762C));
    canvas.save();
    canvas.clipPath(stairs);
    final hatch = Paint()
      ..color = const Color(0xFFB64B15)
      ..strokeWidth = 1;
    for (var x = -100.0; x <= 160; x += 7) {
      canvas.drawLine(Offset(x, 146), Offset(x + 80, 60), hatch);
    }
    canvas.restore();
    canvas.drawLine(
        const Offset(22, 122),
        const Offset(150, 122),
        Paint()
          ..color = const Color(0xFF242522)
          ..strokeWidth = 2);
    final arrow = Path()
      ..moveTo(32, 70)
      ..lineTo(102, 20)
      ..moveTo(88, 20)
      ..lineTo(102, 20)
      ..lineTo(102, 34);
    canvas.drawPath(
        arrow,
        Paint()
          ..color = const Color(0xFF242522)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StepPainter oldDelegate) => false;
}
