import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/widgets/adaptive_canvas_shell.dart';
import 'package:innocence_flutter/core/widgets/glass_motion_backdrop.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/secondary_page_scaffold.dart';
import 'package:innocence_flutter/core/widgets/minimal_white_backdrop.dart';

void main() {
  testWidgets('canvas shell uses every visual theme token set', (tester) async {
    for (final visualTheme in AppVisualTheme.values) {
      final tokens = AppVisualTokens.of(visualTheme);
      await tester.pumpWidget(
        MaterialApp(
          theme: tokens.toThemeData(visualTheme),
          home: SizedBox(
            width: 920,
            height: 760,
            child: AdaptiveCanvasShell(
              visualTheme: visualTheme,
              destinations: const [
                AdaptiveCanvasDestination(
                  id: 'home',
                  label: 'Home',
                  icon: Icons.home_outlined,
                ),
              ],
              selectedDestinationId: 'home',
              onDestinationSelected: (_) {},
              pageTitle: 'Home',
              userDisplayName: 'I',
              bodyBuilder: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(
        scaffold.backgroundColor,
        tokens.canvas,
      );
    }
  });

  testWidgets('glass secondary pages share the animated backdrop',
      (tester) async {
    const visualTheme = AppVisualTheme.glass;
    final tokens = AppVisualTokens.of(visualTheme);

    await tester.pumpWidget(
      MaterialApp(
        theme: tokens.toThemeData(visualTheme),
        home: const SecondaryPageScaffold(
          visualTheme: visualTheme,
          backLabel: 'Back',
          title: 'Settings',
          description: 'Appearance settings',
          children: [SizedBox(height: 80)],
        ),
      ),
    );

    expect(find.byType(GlassMotionBackdrop), findsOneWidget);
  });

  testWidgets('minimal white canvas and secondary pages share the backdrop',
      (tester) async {
    const visualTheme = AppVisualTheme.minimalism;
    final tokens = AppVisualTokens.of(visualTheme);

    await tester.pumpWidget(
      MaterialApp(
        theme: tokens.toThemeData(visualTheme),
        home: AdaptiveCanvasShell(
          visualTheme: visualTheme,
          destinations: const [
            AdaptiveCanvasDestination(
              id: 'home',
              label: 'Home',
              icon: Icons.home_outlined,
            ),
          ],
          selectedDestinationId: 'home',
          onDestinationSelected: (_) {},
          pageTitle: 'Home',
          userDisplayName: 'I',
          bodyBuilder: (_, __) => const SizedBox.shrink(),
        ),
      ),
    );
    expect(find.byType(MinimalWhiteBackdrop), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: tokens.toThemeData(visualTheme),
        home: const SecondaryPageScaffold(
          visualTheme: visualTheme,
          backLabel: 'Back',
          title: 'Settings',
          description: 'Appearance settings',
          children: [SizedBox(height: 80)],
        ),
      ),
    );
    expect(find.byType(MinimalWhiteBackdrop), findsOneWidget);
  });

  testWidgets('light-style panels still follow the active glass theme',
      (tester) async {
    const visualTheme = AppVisualTheme.glass;
    final tokens = AppVisualTokens.of(visualTheme);

    await tester.pumpWidget(
      MaterialApp(
        theme: tokens.toThemeData(visualTheme),
        home: const Scaffold(
          body: GlassPanel(
            lightStyle: true,
            child: Text('Theme-aware panel'),
          ),
        ),
      ),
    );

    final panel = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    final decoration = panel.decoration! as BoxDecoration;
    expect(
        decoration.color,
        AppConfig.deviceType == 'windows'
            ? const Color(0x0AFFFFFF)
            : const Color(0x33000000));
    expect(decoration.color, isNot(Colors.white));
  });
}
