import 'package:flutter/material.dart';

/// A crisp white workspace on the neutral grey canvas, without blur or shadow.
class WhiteSurfacePanel extends StatelessWidget {
  const WhiteSurfacePanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 0,
    this.hovered = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.white,
        border: Border.all(
            color: hovered ? const Color(0xFF9B9B9B) : const Color(0xFFD6D6D6)),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
