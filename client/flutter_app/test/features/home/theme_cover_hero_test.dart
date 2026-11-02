import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/widgets/theme_cover_hero.dart';
import 'package:innocence_flutter/features/focus/presentation/widgets/start_focus_session_dialog.dart';
import 'android_home_shell_test.dart' show androidHomeFixture;
import 'desktop_daily_slogan_test.dart' show desktopSloganFixture;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('CoverQa')
          ..addFont(Future.value(ByteData.sublistView(
              await File(r'C:\Windows\Fonts\msyh.ttc').readAsBytes()))))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
    for (final entry in [
      ('CrimsonText', 'assets/fonts/crimson_text/CrimsonText-Regular.ttf'),
      ('NotoSerifSC', 'assets/fonts/noto_serif_sc/NotoSerifSC-Variable.ttf'),
    ]) {
      await (FontLoader(entry.$1)..addFont(rootBundle.load(entry.$2))).load();
    }
  });
  for (final theme
      in AppVisualTheme.values.where((t) => t != AppVisualTheme.minimalism)) {
    for (final width in [320.0, 1360.0]) {
      testWidgets(
          'themed cover ${theme.name} at $width retains identity in both languages',
          (tester) async {
        tester.view.physicalSize = Size(width, width == 320 ? 1200 : 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final language in AppLanguage.values) {
          final root = GlobalKey();
          final fixture = width == 320
              ? androidHomeFixture(
                  visualTheme: theme,
                  language: language,
                  fontFamily: 'CoverQa',
                  textScale: 1.5)
              : desktopSloganFixture(theme, language, fontFamily: 'CoverQa');
          await tester.pumpWidget(RepaintBoundary(key: root, child: fixture));
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.byType(ThemeCoverHero), findsOneWidget);
          expect(find.byKey(ValueKey('theme-cover-title-${theme.name}')),
              findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.runAsync(() async {
            final image = await (root.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            final folder = Directory('build/qa/theme-covers');
            await folder.create(recursive: true);
            await File(
                    '${folder.path}/${theme.name}-${width.toInt()}-${language.storageValue}.png')
                .writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  testWidgets(
      'custom focus rejects empty zero and oversized durations then starts exactly 37 minutes',
      (tester) async {
    tester.view.physicalSize = const Size(460, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FocusSessionDraft? result;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () async {
                      result = await showDialog<FocusSessionDraft>(
                          context: context,
                          builder: (_) => const StartFocusSessionDialog());
                    },
                    child: const Text('open'))))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final input = find.byKey(const ValueKey('custom-focus-minutes'));
    for (final invalid in ['', '0', '1441']) {
      await tester.enterText(input, invalid);
      await tester.tap(find.text('Start'));
      await tester.pump();
      expect(find.text('Enter a focus duration from 1 to 1440 minutes.'),
          findsOneWidget);
      expect(result, isNull);
    }
    await tester.enterText(input, '37');
    final before = DateTime.now();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(result!.endTime.difference(before).inSeconds,
        inInclusiveRange(2219, 2221));
    expect(result!.bindPomodoro, isFalse);
  });
}
