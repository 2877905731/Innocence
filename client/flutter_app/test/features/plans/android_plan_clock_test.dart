import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/plans/presentation/widgets/today_plan_editor_dialog.dart';

const _captureKey = ValueKey('clock-test-capture');
const _faceKey = ValueKey('today-plan-clock-face');

TodayPlanItem _item(int start, int end) => TodayPlanItem(
      id: 1,
      title: '已有任务',
      completed: false,
      plannedMinutes: (end - start) * 30,
      actualMinutes: 0,
      startSlot: start,
      endSlot: end,
      sortOrder: 0,
    );

Future<void> _open(
  WidgetTester tester, {
  List<TodayPlanItem> items = const [],
  Future<void> Function(TodayPlan)? onSave,
  AppVisualTheme theme = AppVisualTheme.minimalism,
  Size size = const Size(390, 844),
  double fontScale = 1,
  Locale locale = const Locale('zh', 'CN'),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(RepaintBoundary(
    key: _captureKey,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppVisualTokens.of(theme).toThemeData(theme),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(fontScale)),
        child: child!,
      ),
      home: Builder(
          builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => TodayPlanEditorDialog(
                      initialPlan:
                          TodayPlan.empty('2026-10-01').copyWith(items: items),
                      onSave: onSave ?? (_) async {},
                    ),
                  ),
                  child: const Text('打开'),
                ),
              )),
    ),
  ));
  await tester.tap(find.text('打开'));
  await tester.pumpAndSettle();
}

Offset _point(WidgetTester tester, double slot, {double radiusOffset = 0}) {
  final rect = tester.getRect(find.byKey(_faceKey));
  final radius = rect.width / 2 - 36 + radiusOffset;
  final angle = slot / 48 * 2 * math.pi - math.pi / 2;
  return rect.center +
      Offset(math.cos(angle) * radius, math.sin(angle) * radius);
}

Future<void> _tap(WidgetTester tester, int slot) async {
  if (find.byKey(_faceKey).evaluate().isEmpty) {
    await tester.scrollUntilVisible(find.byKey(_faceKey), -160,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('android-plan-editor-scroll')),
              matching: find.byType(Scrollable),
            )
            .first);
  }
  await tester.ensureVisible(find.byKey(_faceKey));
  await tester.pumpAndSettle();
  await tester.tapAt(_point(tester, slot.toDouble()));
  await tester.pump();
}

Future<void> _drag(WidgetTester tester, double from, double to,
    {required bool start}) async {
  await tester.ensureVisible(find.byKey(_faceKey));
  await tester.pumpAndSettle();
  final offset = start ? 10.0 : -10.0;
  final gesture =
      await tester.startGesture(_point(tester, from, radiusOffset: offset));
  for (var i = 1; i <= 12; i++) {
    await gesture.moveTo(
        _point(tester, from + (to - from) * i / 12, radiusOffset: offset));
    await tester.pump();
  }
  await gesture.up();
  await tester.pump();
}

Future<void> _capture(WidgetTester tester, String name) async {
  final directory = Platform.environment['INNOCENCE_CAPTURE_DIR'];
  if (directory == null) return;
  await tester.pumpAndSettle();
  final boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byKey(_captureKey));
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(directory).create(recursive: true);
    await File('$directory/$name.png').writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void _testAndroid(
    String description, Future<void> Function(WidgetTester) callback) {
  testWidgets(description, callback,
      variant: TargetPlatformVariant.only(TargetPlatform.android));
}

void main() {
  setUpAll(() async {
    if (Platform.environment['INNOCENCE_CAPTURE_DIR'] == null) return;
    final textFontPath = Platform.environment['INNOCENCE_CAPTURE_FONT'];
    final iconFontPath = Platform.environment['INNOCENCE_CAPTURE_ICON_FONT'];
    if (textFontPath == null || iconFontPath == null) return;
    final textFont = FontLoader('Segoe UI')
      ..addFont(File(textFontPath)
          .readAsBytes()
          .then((bytes) => ByteData.sublistView(bytes)));
    final iconFont = FontLoader('MaterialIcons')
      ..addFont(File(iconFontPath)
          .readAsBytes()
          .then((bytes) => ByteData.sublistView(bytes)));
    await textFont.load();
    await iconFont.load();
  });
  _testAndroid(
      'Android clock saves exact dawn endpoints and can continue editing',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final saved = <TodayPlan>[];
    await _open(tester, onSave: (plan) async => saved.add(plan));
    expect(find.byKey(_faceKey), findsOneWidget);
    expect(find.byKey(const ValueKey('today-plan-slot-0')), findsNothing);
    await _tap(tester, 0);
    await _tap(tester, 3);
    await tester.tap(find.byKey(const ValueKey('today-plan-save')));
    await tester.pumpAndSettle();
    expect(saved.single.items.single.startSlot, 0);
    expect(saved.single.items.single.endSlot, 3);
    expect(saved.single.items.single.plannedMinutes, 90);
    expect(saved.single.planDate, '2026-10-01');
    expect(find.text('短计划时间安排'), findsOneWidget);
    await tester
        .ensureVisible(find.byKey(const ValueKey('plan-clock-end-later')));
    await tester.tap(find.byKey(const ValueKey('plan-clock-end-later')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('today-plan-save')));
    await tester.pumpAndSettle();
    expect(saved.last.items.single.endSlot, 4);
    expect(tester.takeException(), isNull);
  });

  _testAndroid('the top is 24:00 when ending a late-night block',
      (tester) async {
    TodayPlan? saved;
    await _open(tester, onSave: (plan) async => saved = plan);
    await _tap(tester, 46);
    await _tap(tester, 0);
    await tester.tap(find.byKey(const ValueKey('today-plan-save')));
    await tester.pumpAndSettle();
    expect(saved!.items.single.startSlot, 46);
    expect(saved!.items.single.endSlot, 48);
    expect(saved!.items.single.plannedMinutes, 60);
    expect(find.text('23:00\n24:00'), findsOneWidget);
  });

  _testAndroid(
      'overlap and reversed same-day endpoints retain the anchor without saving',
      (tester) async {
    var saves = 0;
    await _open(tester, items: [_item(2, 4)], onSave: (_) async => saves++);
    await _tap(tester, 0);
    await _tap(tester, 6);
    expect(find.text('该时间段与已有任务重叠。'), findsOneWidget);
    expect(find.text('00:00 →'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('today-plan-save')))
            .onPressed,
        isNull);
    await tester
        .ensureVisible(find.byKey(const ValueKey('plan-clock-clear-anchor')));
    await tester.tap(find.byKey(const ValueKey('plan-clock-clear-anchor')));
    await tester.pump();
    await _tap(tester, 44);
    expect(find.text('22:00 →'), findsOneWidget);
    await _tap(tester, 2);
    expect(find.text('22:00 →'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('结束时间须晚于开始时间'), 120,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('android-plan-editor-scroll')),
              matching: find.byType(Scrollable),
            )
            .first);
    expect(find.textContaining('结束时间须晚于开始时间'), findsOneWidget);
    expect(saves, 0);
    expect(tester.takeException(), isNull);
  });

  _testAndroid('occupied blocks select and resizing stops at adjacent blocks',
      (tester) async {
    TodayPlan? saved;
    await _open(tester,
        items: [_item(0, 2), _item(4, 6)],
        onSave: (plan) async => saved = plan);
    await _tap(tester, 1);
    expect(find.text('00:00\n01:00'), findsOneWidget);
    await _drag(tester, 2, 8, start: false);
    await tester.tap(find.byKey(const ValueKey('today-plan-save')));
    await tester.pumpAndSettle();
    expect(saved!.items, hasLength(2));
    expect(saved!.items.first.startSlot, 0);
    expect(saved!.items.first.endSlot, 4);
    expect(saved!.items.last.startSlot, 4);
    await _drag(tester, 0, 8, start: true);
    await tester.tap(find.byKey(const ValueKey('today-plan-save')));
    await tester.pumpAndSettle();
    expect(saved!.items.first.startSlot, 3);
    expect(saved!.items.first.endSlot, 4);
  });

  _testAndroid(
      'dragging dawn through midnight clamps to 00:00 instead of wrapping',
      (tester) async {
    TodayPlan? saved;
    await _open(tester,
        items: [_item(1, 4)], onSave: (plan) async => saved = plan);
    await _tap(tester, 2);
    await _drag(tester, 1, -2, start: true);
    await tester.tap(find.byKey(const ValueKey('today-plan-save')));
    await tester.pumpAndSettle();
    expect(saved!.items.single.startSlot, 0);
    expect(saved!.items.single.endSlot, 4);
  });

  _testAndroid('late-night end drag stops at 24:00 and can move back',
      (tester) async {
    TodayPlan? saved;
    await _open(tester,
        items: [_item(44, 46)], onSave: (plan) async => saved = plan);
    await _tap(tester, 45);
    await _drag(tester, 46, 50, start: false);
    await tester.tap(find.byKey(const ValueKey('today-plan-save')));
    await tester.pumpAndSettle();
    expect(saved!.items.single.startSlot, 44);
    expect(saved!.items.single.endSlot, 48);
    await _drag(tester, 48, 47, start: false);
    await tester.tap(find.byKey(const ValueKey('today-plan-save')));
    await tester.pumpAndSettle();
    expect(saved!.items.single.endSlot, 47);
  });

  _testAndroid('clock center and clearing an anchor do not change the plan',
      (tester) async {
    await _open(tester);
    await tester.tapAt(tester.getCenter(find.byKey(_faceKey)));
    await tester.pump();
    expect(find.text('请选择结束时间'), findsNothing);
    await _tap(tester, 0);
    await tester
        .ensureVisible(find.byKey(const ValueKey('plan-clock-clear-anchor')));
    await tester.tap(find.byKey(const ValueKey('plan-clock-clear-anchor')));
    await tester.pump();
    expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('today-plan-save')))
            .onPressed,
        isNull);
    expect(find.text('选择时间段'), findsOneWidget);
  });

  _testAndroid(
      'accessible time entry rejects non-half-hours and saves dawn without touch on the ring',
      (tester) async {
    TodayPlan? saved;
    await _open(tester, onSave: (plan) async => saved = plan);
    Future<void> enterTime(String hour, String minute) async {
      final button = find.byKey(const ValueKey('plan-clock-accessible-time'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      final fields = find.descendant(
          of: find.byType(TimePickerDialog), matching: find.byType(TextField));
      await tester.enterText(fields.first, hour);
      await tester.enterText(fields.last, minute);
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
    }

    await enterTime('00', '15');
    expect(find.text('请选择整点或半点。'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('today-plan-save')))
            .onPressed,
        isNull);
    await enterTime('00', '30');
    await enterTime('02', '00');
    await tester.tap(find.byKey(const ValueKey('today-plan-save')));
    await tester.pumpAndSettle();
    expect(saved!.items.single.startSlot, 1);
    expect(saved!.items.single.endSlot, 4);
    expect(tester.takeException(), isNull);
  });

  for (final theme in [AppVisualTheme.minimalism, AppVisualTheme.glass]) {
    _testAndroid(
        '${theme.name} clock keeps save available with narrow large text and keyboard',
        (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await _open(tester,
          theme: theme, size: const Size(320, 720), fontScale: 1.5);
      await _tap(tester, 0);
      await _tap(tester, 4);
      await _capture(tester, 'android-clock-${theme.name}-320-large-text');
      expect(tester.takeException(), isNull);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      final saveRect =
          tester.getRect(find.byKey(const ValueKey('today-plan-save')));
      expect(saveRect.bottom, lessThanOrEqualTo(440));
      await tester.tap(find.byKey(const ValueKey('today-plan-save')));
      await tester.pumpAndSettle();
      expect(find.text('当天计划已保存'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  _testAndroid('English landscape editor remains scrollable with fixed actions',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _open(tester,
        size: const Size(844, 390),
        fontScale: 1.5,
        locale: const Locale('en', 'US'));
    expect(find.text('Short plan scheduler'), findsOneWidget);
    await tester.ensureVisible(find.byKey(_faceKey));
    await tester.pump();
    expect(tester.getRect(find.byKey(const ValueKey('today-plan-save'))).bottom,
        lessThan(390));
    expect(tester.takeException(), isNull);
  });
}
