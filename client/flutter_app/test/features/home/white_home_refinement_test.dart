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
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'desktop_daily_slogan_test.dart' show desktopSloganFixture;
import 'android_home_shell_test.dart' show androidHomeFixture;

class WhiteHomeTestBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get disableShadows => false;
}

FocusSession session(
        {int elapsed = 450, int remaining = 1350, bool paused = false}) =>
    FocusSession.fromJson({
      'active': true,
      'paused': paused,
      'elapsedSeconds': elapsed,
      'remainingSeconds': remaining,
      'taskName': '英语阅读',
      'plannedMinutes': 30,
      'stageName': 'study',
    });

TodayPlan previewPlan() => TodayPlan.fromJson({
      'planDate': '2026-10-04',
      'items': [
        {'title': '整理学习笔记', 'startSlot': 18, 'endSlot': 20, 'completed': true},
        {
          'title': '阅读与章节札记',
          'startSlot': 28,
          'endSlot': 31,
          'completed': false
        },
      ],
    });

Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final folder = Directory('build/qa/minimal-white-rebuild');
    await folder.create(recursive: true);
    await File('${folder.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  WhiteHomeTestBinding();
  String? qaFont;
  setUpAll(() async {
    final font = File(r'C:\Windows\Fonts\msyh.ttc');
    if (await font.exists()) {
      await (FontLoader('WhiteHomeQa')
            ..addFont(
                Future.value(ByteData.sublistView(await font.readAsBytes()))))
          .load();
      qaFont = 'WhiteHomeQa';
    }
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  testWidgets(
      'desktop dial follows the displayed session across tick, pause, finish and restart',
      (tester) async {
    tester.view.physicalSize = const Size(1360, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Future<FocusTimerDialPainter> show(FocusSession value) async {
      await tester.pumpWidget(desktopSloganFixture(
          AppVisualTheme.minimalism, AppLanguage.simplifiedChinese,
          focusSession: value));
      await tester.pump();
      expect(find.text(value.active ? value.remainingLabel : '00:00'),
          findsOneWidget);
      final dial = tester.widget<FocusTimerDial>(find.byType(FocusTimerDial));
      expect(dial.session, same(value));
      return tester
          .widget<CustomPaint>(
              find.byKey(const ValueKey('focus-timer-dial-face')))
          .painter! as FocusTimerDialPainter;
    }

    final start = session();
    final first = await show(start);
    expect(first.progress, .25);
    final advanced = await show(start.tick());
    expect(advanced.secondAngle, isNot(first.secondAngle));
    expect(advanced.minuteAngle, isNot(first.minuteAngle));
    expect(advanced.progress, greaterThan(first.progress));
    final paused = session(elapsed: 451, remaining: 1349, paused: true);
    final frozen = await show(paused);
    await tester.pump(const Duration(seconds: 10));
    final frozenAgain = await show(paused.tick());
    expect(frozenAgain.secondAngle, frozen.secondAngle);
    expect(frozenAgain.progress, frozen.progress);
    expect(frozenAgain.paused, true);
    final resumed = await show(session(elapsed: 451, remaining: 1349).tick());
    expect(resumed.progress, greaterThan(frozen.progress));
    final finished = await show(session(elapsed: 1799, remaining: 1).tick());
    expect(finished.progress, 1);
    final stoppedEarly = await show(FocusSession.fromJson({
      'active': false,
      'elapsedSeconds': 450,
      'remainingSeconds': 0,
      'plannedMinutes': 30,
      'stageName': 'finished',
    }));
    expect(stoppedEarly.progress, .25);
    final idle = await show(FocusSession.empty());
    expect(idle.progress, 0);
    final restarted = await show(session(elapsed: 0, remaining: 1800));
    expect(restarted.progress, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final width in [460.0, 820.0, 1360.0]) {
    testWidgets('minimal white desktop layout and timer at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final root = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
          key: root,
          child: desktopSloganFixture(
              AppVisualTheme.minimalism, AppLanguage.simplifiedChinese,
              focusSession: session(),
              todayPlan: previewPlan(),
              textScale: width == 460 ? 1.5 : 1,
              fontFamily: qaFont)));
      await tester.pump(const Duration(milliseconds: 350));
      final dial = find.byType(FocusTimerDial);
      if (width == 460) {
        await capture(tester, root, 'desktop-460-top');
        await tester.ensureVisible(dial);
      }
      await tester.pump();
      expect(find.textContaining('每日标语'), findsNothing);
      expect(tester.takeException(), isNull);
      await capture(tester, root, 'desktop-${width.toInt()}');
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final theme in [AppVisualTheme.minimalism, AppVisualTheme.glass]) {
    testWidgets(
        'Android timer and label removal ${theme.name} at 320 with large text',
        (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final root = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
          key: root,
          child: androidHomeFixture(
              offline: true,
              visualTheme: theme,
              focusSession: session(),
              todayPlan: previewPlan(),
              textScale: 1.5,
              fontFamily: qaFont)));
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('每日标语'), findsNothing);
      expect(find.text('Daily inspiration'), findsNothing);
      await capture(tester, root, 'android-${theme.name}-top');
      final slogan = find.byKey(const ValueKey('android-daily-slogan'));
      await tester.scrollUntilVisible(slogan, 180,
          scrollable: find.byType(Scrollable).first);
      await tester.pump();
      expect(tester.takeException(), isNull);
      await capture(tester, root, 'android-${theme.name}-slogan');
      final dial = find.byType(FocusTimerDial);
      await tester.scrollUntilVisible(dial, 180,
          scrollable: find.byType(Scrollable).first);
      await tester.pump();
      expect(tester.widget<FocusTimerDial>(dial).session.elapsedSeconds, 450);
      expect(tester.takeException(), isNull);
      await capture(tester, root, 'android-${theme.name}-dial');
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
