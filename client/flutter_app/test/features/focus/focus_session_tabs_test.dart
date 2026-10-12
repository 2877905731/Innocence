import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';
import 'package:innocence_flutter/features/focus/presentation/widgets/focus_session_tabs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('PomodoroQa')
          ..addFont(Future.value(ByteData.sublistView(
              await File(r'C:\Windows\Fonts\msyh.ttc').readAsBytes()))))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  for (final theme in AppVisualTheme.values) {
    for (final width in [320.0, 900.0]) {
      testWidgets(
          'pomodoro tabs ${theme.name} at $width preserve draft and validate settings',
          (tester) async {
        tester.view.physicalSize = Size(width, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final root = GlobalKey();
        var saves = 0;
        Future<void> save(
            {required bool bindPomodoro,
            required int pomodoroStudyMinutes,
            required int pomodoroBreakMinutes}) async {
          expect(bindPomodoro, isTrue);
          expect(pomodoroStudyMinutes, 40);
          expect(pomodoroBreakMinutes, 0);
          saves++;
        }

        final focus = FocusSession.fromJson(
            {'sessionId': 7, 'active': true, 'remainingSeconds': 3600});
        Widget fixture(FocusSession session) => RepaintBoundary(
            key: root,
            child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppVisualTokens.of(theme).toThemeData(theme).copyWith(
                    textTheme: AppVisualTokens.of(theme)
                        .toThemeData(theme)
                        .textTheme
                        .apply(fontFamily: 'PomodoroQa')),
                home: Scaffold(
                    body: MediaQuery(
                        data: MediaQueryData(
                            textScaler:
                                TextScaler.linear(width == 320 ? 1.5 : 1)),
                        child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: FocusSessionTabs(
                                session: session,
                                isChinese: true,
                                isBusy: false,
                                timer: const Text('TOTAL_TIMER'),
                                onConfigure: save))))));
        await tester.pumpWidget(fixture(focus));
        await tester.tap(find.byKey(const ValueKey('focus-pomodoro-tab')));
        await tester.pump();
        await tester.enterText(
            find.byKey(const ValueKey('pomodoro-study-minutes')), '0');
        await tester.ensureVisible(find.byKey(const ValueKey('pomodoro-save')));
        await tester.tap(find.byKey(const ValueKey('pomodoro-save')));
        await tester.pump();
        expect(saves, 0);
        expect(find.text('请输入范围内的整数'), findsOneWidget);
        await tester.enterText(
            find.byKey(const ValueKey('pomodoro-study-minutes')), '40');
        await tester.enterText(
            find.byKey(const ValueKey('pomodoro-break-minutes')), '0');
        await tester.pumpWidget(fixture(focus.tick()));
        expect(
            tester
                .widget<TextFormField>(
                    find.byKey(const ValueKey('pomodoro-study-minutes')))
                .controller!
                .text,
            '40');
        await tester.ensureVisible(find.byKey(const ValueKey('pomodoro-save')));
        await tester.tap(find.byKey(const ValueKey('pomodoro-save')));
        await tester.pump();
        expect(saves, 1);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(fixture(FocusSession.fromJson({
          'sessionId': 7,
          'active': true,
          'paused': width == 320,
          'elapsedSeconds': 1560,
          'remainingSeconds': 2040,
          'bindPomodoro': true,
          'pomodoroStudyMinutes': 25,
          'pomodoroBreakMinutes': 5
        })));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.runAsync(() async {
          final boundary =
              root.currentContext!.findRenderObject() as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final folder = Directory('build/qa/pomodoro-tabs');
          await folder.create(recursive: true);
          await File('${folder.path}/${theme.name}-${width.toInt()}.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.tap(find.byKey(const ValueKey('focus-timer-tab')));
        await tester.pump();
        expect(find.text('TOTAL_TIMER'), findsOneWidget);
      });
    }
  }
}
