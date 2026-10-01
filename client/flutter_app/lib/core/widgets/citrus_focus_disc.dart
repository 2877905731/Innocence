import 'dart:ui';

import 'package:flutter/material.dart';

/// A single citrus light source crossing a frosted split. The same material
/// study is used in the desktop focus panel and the Android focus summary.
class CitrusFocusDisc extends StatelessWidget {
  const CitrusFocusDisc({super.key, this.size = 156});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFD794),
                    Color(0xFFF49A43),
                    Color(0xFFED762C)
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: size * .52,
                height: size,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 23, sigmaY: 23),
                    child: const ColoredBox(color: Color(0x65F1EFEA)),
                  ),
                ),
              ),
            ),
            Positioned(
              left: size * .52,
              top: 0,
              bottom: 0,
              child: const ColoredBox(
                  color: Color(0x66FFFFFF), child: SizedBox(width: 1)),
            ),
          ],
        ),
      ),
    );
  }
}
