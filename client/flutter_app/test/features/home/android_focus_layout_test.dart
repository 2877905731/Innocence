import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/widgets/focus_timer_dial.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';
import 'android_home_shell_test.dart' show androidHomeFixture;

class FocusLayoutTestBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get disableShadows => false;
}

void main() {
  FocusLayoutTestBinding();
  String? qaFont;
  setUpAll(() async {
    final font = File(r'C:\Windows\Fonts\msyh.ttc');
    if (await font.exists()) {
      await (FontLoader('FocusLayoutQa')
            ..addFont(
                Future.value(ByteData.sublistView(await font.readAsBytes()))))
          .load();
      qaFont = 'FocusLayoutQa';
    }
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final folder = Directory('build/qa/android-focus-layout');
      await folder.create(recursive: true);
      await File('${folder.path}/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  for (final theme in AppVisualTheme.values) {
    for (final layout in [
      (411.0, 900.0, 1.0),
      (320.0, 900.0, 1.5),
      (600.0, 500.0, 1.5)
    ]) {
      testWidgets(
          'Android focus ${theme.name} at ${layout.$1} scale ${layout.$3}',
          (tester) async {
        tester.view.physicalSize = Size(layout.$1, layout.$2);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final language in AppLanguage.values) {
          for (final state in ['idle', 'running', 'paused']) {
            final session = state == 'idle'
                ? FocusSession.empty()
                : FocusSession.fromJson({
                    'active': true,
                    'paused': state == 'paused',
                    'taskName': language.isChinese
                        ? '整理英语阅读中的重点句式并完成本章学习笔记'
                        : 'Review the key sentences and finish the notes for this chapter',
                    'elapsedSeconds': 450,
                    'remainingSeconds': 4950,
                    'plannedMinutes': 90,
                    'stageName': 'study',
                  });
            var starts = 0, toggles = 0, finishes = 0;
            final root = GlobalKey();
            await tester.pumpWidget(RepaintBoundary(
                key: root,
                child: androidHomeFixture(
                  offline: true,
                  visualTheme: theme,
                  language: language,
                  textScale: layout.$3,
                  fontFamily: qaFont,
                  focusSession: session,
                  onStartFocus: () async {
                    starts++;
                  },
                  onToggleFocusPause: () async {
                    toggles++;
                  },
                  onFinishFocus: () async {
                    finishes++;
                  },
                )));
            await tester.pump(const Duration(milliseconds: 350));
            final summary = find.byKey(const ValueKey('android-focus-summary'));
            await tester.scrollUntilVisible(summary, 180,
                scrollable: find.byType(Scrollable).first);
            await tester.pump();
            final time = find.byKey(const ValueKey('android-focus-time'));
            final open = find.byKey(const ValueKey('android-focus-open'));
            final dial = find.byType(FocusTimerDial);
            expect(tester.widget<Text>(time).data,
                session.active ? '01:22:30' : '00:00');
            final digits = tester.renderObject<RenderParagraph>(time);
            final digitBoxes = digits.getBoxesForSelection(TextSelection(
                baseOffset: 0,
                extentOffset: tester.widget<Text>(time).data!.length));
            expect(digitBoxes.map((box) => box.top).toSet(), hasLength(1));
            expect(tester.widget<FocusTimerDial>(dial).session, same(session));
            expect(tester.getSize(open).height, greaterThanOrEqualTo(48));
            expect(tester.getSize(open).width,
                greaterThan(tester.getSize(summary).width - 50));
            if (layout.$1 == 411 && state == 'idle') {
              final timeRect = tester.getRect(time),
                  dialRect = tester.getRect(dial);
              expect(timeRect.right, lessThan(dialRect.left));
              expect(timeRect.center.dy,
                  inInclusiveRange(dialRect.top, dialRect.bottom));
              expect(tester.getSize(summary).height, lessThan(300));
            }
            expect(tester.takeException(), isNull);
            final save = language.isChinese &&
                ((layout.$1 == 411 &&
                        state == 'idle' &&
                        [AppVisualTheme.wabiSabi, AppVisualTheme.minimalism]
                            .contains(theme)) ||
                    (layout.$1 == 411 &&
                        state == 'running' &&
                        theme == AppVisualTheme.glass) ||
                    (layout.$1 == 320 &&
                        state == 'paused' &&
                        theme == AppVisualTheme.minimalism));
            final name = '${theme.name}-$state-${layout.$1.toInt()}';
            if (save) await capture(tester, root, '$name-home');
            await tester.ensureVisible(open);
            await tester.tap(open);
            await tester.pumpAndSettle();
            expect(find.byKey(const ValueKey('android-focus-session')),
                findsOneWidget);
            expect(
                tester
                    .widget<FocusTimerDial>(find.byType(FocusTimerDial))
                    .session,
                same(session));
            if (save) await capture(tester, root, '$name-detail');
            if (session.active) {
              final toggle = find.byKey(const ValueKey('android-focus-toggle'));
              await tester.ensureVisible(toggle);
              await tester.tap(toggle);
              await tester.pump();
              final finish = find.byKey(const ValueKey('android-focus-finish'));
              await tester.ensureVisible(finish);
              await tester.tap(finish);
              await tester.pump();
              expect((starts, toggles, finishes), (0, 1, 1));
            } else {
              final start = find.byKey(const ValueKey('android-focus-start'));
              await tester.ensureVisible(start);
              await tester.tap(start);
              await tester.pump();
              expect((starts, toggles, finishes), (1, 0, 0));
            }
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
          }
        }
      });
    }
  }

  testWidgets('focus actions stay disabled while the existing session is busy',
      (tester) async {
    await tester.pumpWidget(androidHomeFixture(
        isBusy: true,
        focusSession: FocusSession.fromJson({
          'active': true,
          'paused': true,
          'remainingSeconds': 1350,
        })));
    await tester.pump(const Duration(milliseconds: 350));
    final open = find.byKey(const ValueKey('android-focus-open'));
    await tester.scrollUntilVisible(open, 180,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(open);
    await tester.pump();
    await tester.tap(open);
    await tester.pump(const Duration(milliseconds: 350));
    expect(
        tester
            .widget<FilledButton>(
                find.byKey(const ValueKey('android-focus-toggle')))
            .onPressed,
        isNull);
    expect(
        tester
            .widget<OutlinedButton>(
                find.byKey(const ValueKey('android-focus-finish')))
            .onPressed,
        isNull);
    expect(tester.takeException(), isNull);
  });
}
