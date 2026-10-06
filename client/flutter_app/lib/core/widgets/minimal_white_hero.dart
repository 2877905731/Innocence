import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'white_surface_panel.dart';

/// Typography and useful whitespace follow the original minimalism reference.
class MinimalWhiteHero extends StatelessWidget {
  const MinimalWhiteHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.indexLabel,
    this.titleSize = 30,
  });

  final String eyebrow, title, description, indexLabel;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final tokens = AppVisualTokens.of(AppVisualTheme.minimalism);
    return WhiteSurfacePanel(
      key: const ValueKey('minimal-white-hero-surface'),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(builder: (context, constraints) {
        final roomy = constraints.maxWidth >= 720 &&
            MediaQuery.textScalerOf(context).scale(1) <= 1.3;
        final heading = Text(title,
            style: TextStyle(
                color: tokens.ink,
                fontSize: titleSize,
                height: 1.2,
                fontWeight: FontWeight.w300,
                letterSpacing: -1));
        final detail = Text(description,
            style: TextStyle(color: tokens.muted, fontSize: 14, height: 1.7));
        final wordmark = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'Innocence',
              child: ExcludeSemantics(
                child: SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text('INN/CNCE',
                        key: const ValueKey('minimal-white-wordmark'),
                        style: TextStyle(
                            color: tokens.ink,
                            fontSize: roomy ? 80 : 64,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            letterSpacing: -5)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('LESS NOISE. MORE PROGRESS.',
                style: TextStyle(
                    color: tokens.ink,
                    fontSize: 10,
                    height: 1.5,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800)),
          ],
        );
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [heading, const SizedBox(height: 16), detail],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                  child: Text(eyebrow,
                      style: TextStyle(
                          color: tokens.muted,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500))),
              const SizedBox(width: 16),
              Text(indexLabel,
                  style: TextStyle(
                      color: tokens.muted,
                      fontSize: 11,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ]),
            const SizedBox(height: 16),
            Divider(height: 1, color: tokens.line),
            const SizedBox(height: 32),
            if (roomy)
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(flex: 6, child: wordmark),
                const SizedBox(width: 48),
                Expanded(flex: 4, child: copy),
              ])
            else ...[
              wordmark,
              const SizedBox(height: 28),
              copy,
            ],
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }
}
