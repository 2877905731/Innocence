import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/app/wabi_sabi_typography.dart';
import 'glass_panel.dart';
import 'theme_brand_wordmark.dart';

/// The brand leads the cover; the daily message remains a secondary reading.
class ThemeCoverHero extends StatelessWidget {
  const ThemeCoverHero(
      {super.key,
      required this.theme,
      required this.isChinese,
      required this.eyebrow,
      required this.title,
      required this.description,
      required this.indexLabel});

  final AppVisualTheme theme;
  final bool isChinese;
  final String eyebrow, title, description, indexLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = AppVisualTokens.of(theme);
    final wabi = theme == AppVisualTheme.wabiSabi;
    final glass = theme == AppVisualTheme.glass;
    final label = switch (theme) {
      AppVisualTheme.wabiSabi => 'WABI / SABI',
      AppVisualTheme.midCentury => 'MID-CENTURY / MODERN',
      _ => 'LIQUID / GLASS',
    };
    final content = LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 720;
      final brand = ThemeBrandWordmark(
          key: ValueKey('theme-cover-title-${theme.name}'), theme: theme);
      final reading = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eyebrow != 'INNOCENCE') ...[
              Text(eyebrow,
                  style: TextStyle(
                      color: tokens.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1)),
              const SizedBox(height: 10),
            ],
            Text(title,
                style: TextStyle(
                    color: tokens.ink,
                    fontSize: wide ? 20 : 18,
                    height: 1.45,
                    fontWeight: wabi ? FontWeight.w400 : FontWeight.w500,
                    fontFamily: wabi ? WabiSabiTypography.latinFamily : null,
                    fontFamilyFallback:
                        wabi ? WabiSabiTypography.fallback : null)),
            const SizedBox(height: 10),
            Text(description,
                style:
                    TextStyle(color: tokens.muted, fontSize: 13, height: 1.65)),
          ]);
      return Padding(
          padding: EdgeInsets.all(wide ? 32 : 22),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(label,
                      style: TextStyle(
                          color: tokens.muted,
                          fontSize: 10,
                          letterSpacing: 1.6))),
              const SizedBox(width: 12),
              Text(indexLabel,
                  style: TextStyle(
                      color: tokens.muted, fontSize: 10, letterSpacing: 1)),
            ]),
            SizedBox(height: wide ? 24 : 20),
            if (wide)
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(flex: 5, child: brand),
                const SizedBox(width: 36),
                Container(
                    width: 1,
                    height: 100,
                    color: tokens.ink.withValues(alpha: glass ? .16 : .12)),
                const SizedBox(width: 28),
                Expanded(flex: 3, child: reading),
              ])
            else ...[
              brand,
              const SizedBox(height: 20),
              Divider(height: 1, color: tokens.ink.withValues(alpha: .12)),
              const SizedBox(height: 18),
              reading,
            ],
          ]));
    });
    if (glass) {
      return GlassPanel(
          key: const ValueKey('theme-cover-glass'),
          padding: EdgeInsets.zero,
          child: content);
    }
    return Container(
        key: ValueKey('theme-cover-${theme.name}'),
        decoration: BoxDecoration(
            color: tokens.panel,
            borderRadius: wabi
                ? BorderRadius.zero
                : const BorderRadius.only(
                    topRight: Radius.circular(48),
                    bottomLeft: Radius.circular(16))),
        child: content);
  }
}
