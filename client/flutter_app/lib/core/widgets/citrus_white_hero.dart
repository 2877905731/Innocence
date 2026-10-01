import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';

import 'citrus_focus_disc.dart';
import 'white_frosted_panel.dart';

/// The slogan has its own floating surface; citrus stays in small details.
class CitrusWhiteHero extends StatelessWidget {
  const CitrusWhiteHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.indexLabel,
    this.titleSize = 34,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String indexLabel;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final tokens = AppVisualTokens.of(AppVisualTheme.minimalism);
    return WhiteFrostedPanel(
      key: const ValueKey('citrus-white-hero-surface'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final roomy = constraints.maxWidth >= 580;
          return Stack(
            children: [
              Positioned(
                right: roomy ? 22 : -24,
                bottom: roomy ? 16 : -18,
                child: ExcludeSemantics(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: roomy ? 1 : .2,
                      child: CitrusFocusDisc(size: roomy ? 128 : 110),
                    ),
                  ),
                ),
              ),
              if (roomy)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: constraints.maxWidth - 84,
                  child: IgnorePointer(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0x66F9F8F4),
                            border: Border(
                              right: BorderSide(
                                color: Colors.white.withValues(alpha: .85),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ExcludeSemantics(
                          child: SizedBox(
                            width: 18,
                            height: 3,
                            child: ColoredBox(color: tokens.accent),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            eyebrow,
                            style: TextStyle(
                              color: tokens.muted,
                              fontSize: 10,
                              letterSpacing: 1.3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: tokens.accent.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: tokens.accent.withValues(alpha: .18)),
                          ),
                          child: Text(
                            indexLabel,
                            style: const TextStyle(
                              color: Color(0xFFA84B15),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Padding(
                      padding: EdgeInsets.only(right: roomy ? 148 : 0),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: tokens.ink,
                          fontSize: titleSize,
                          height: 1.16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.only(right: roomy ? 148 : 0),
                      child: Text(
                        description,
                        style: const TextStyle(
                          color: Color(0xFF65665F),
                          fontSize: 13,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
