import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'citrus_step_artwork.dart';
import 'white_surface_panel.dart';

class CitrusWhiteHero extends StatelessWidget {
  const CitrusWhiteHero(
      {super.key,
      required this.eyebrow,
      required this.title,
      required this.description,
      required this.indexLabel,
      this.titleSize = 34});
  final String eyebrow, title, description, indexLabel;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final tokens = AppVisualTokens.of(AppVisualTheme.minimalism);
    return WhiteSurfacePanel(
      key: const ValueKey('citrus-white-hero-surface'),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(builder: (context, constraints) {
        final roomy = constraints.maxWidth >= 560;
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: tokens.ink,
                    fontSize: titleSize,
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -.8)),
            const SizedBox(height: 12),
            Text(description,
                style:
                    TextStyle(color: tokens.muted, fontSize: 13, height: 1.55)),
          ],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              ExcludeSemantics(
                  child: SizedBox(
                      width: 18,
                      height: 3,
                      child: ColoredBox(color: tokens.accent))),
              const SizedBox(width: 9),
              Expanded(
                  child: Text(eyebrow,
                      style: TextStyle(
                          color: tokens.muted,
                          fontSize: 10,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w600))),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF9EEE4),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(indexLabel,
                      style: const TextStyle(
                          color: Color(0xFFA84B15),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()]))),
            ]),
            const SizedBox(height: 22),
            if (roomy)
              Row(children: [
                Expanded(child: copy),
                const SizedBox(width: 28),
                const CitrusStepArtwork()
              ])
            else ...[
              copy,
              const SizedBox(height: 16),
              const Align(
                  alignment: Alignment.centerRight,
                  child: CitrusStepArtwork(width: 106, height: 88))
            ],
          ],
        );
      }),
    );
  }
}
