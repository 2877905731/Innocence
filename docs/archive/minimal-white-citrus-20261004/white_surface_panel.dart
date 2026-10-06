import 'package:flutter/material.dart';

/// Opaque white surfaces remain distinct from the warm grey canvas.
class WhiteSurfacePanel extends StatelessWidget {
  const WhiteSurfacePanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 18,
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
        border: Border.all(color: const Color(0xFFDCD9D2)),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF514536).withValues(alpha: hovered ? .1 : .065),
            blurRadius: hovered ? 28 : 22,
            offset: Offset(0, hovered ? 10 : 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
