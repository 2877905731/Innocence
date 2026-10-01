import 'dart:ui';

import 'package:flutter/material.dart';

/// Opt-in light frost for floating information surfaces in the white theme.
/// Keep the shadow outside the clip and blur only the backdrop, never content.
class WhiteFrostedPanel extends StatelessWidget {
  const WhiteFrostedPanel({
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
        border: Border.all(color: const Color(0x1F8B8274)),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF514536).withValues(alpha: hovered ? .09 : .055),
            blurRadius: hovered ? 28 : 22,
            offset: Offset(0, hovered ? 10 : 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xD9FFFFFF), Color(0xA6F9F7F2)],
              ),
              border: Border.all(color: const Color(0xD9FFFFFF)),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
