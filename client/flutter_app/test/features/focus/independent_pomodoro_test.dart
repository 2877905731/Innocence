import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/features/focus/application/pomodoro_controller.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';
import 'package:innocence_flutter/features/focus/domain/models/pomodoro_timer.dart';
import 'package:innocence_flutter/features/focus/presentation/widgets/focus_session_tabs.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('PomodoroQa')
          ..addFont(Future.value(ByteData.sublistView(
              await File(r'C:\Windows\Fonts\msyh.ttc').readAsBytes()))))
        .load();
  });
  late Directory folder;
  late OfflineStore store;
  late PomodoroController controller;
  String? owner;
  late int now;
  final native = <MethodCall>[];
  setUp(() async {
    sqfliteFfiInit();
    folder = await Directory.systemTemp.createTemp('independent-pomodoro-');
    store = OfflineStore(
        databaseFactory: databaseFactoryFfi,
        databasePathProvider: () async => '${folder.path}/qa.db');
    await store.initialize();
    now = 1800000000000;
    owner = 'local:independent-qa';
    native.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('innocence/focus_notice'),
            (call) async {
      native.add(call);
      return call.method == 'syncPomodoro' ? 'available' : null;
    });
    controller = PomodoroController(
        store: store,
        owner: () => owner,
        chinese: () => true,
        platform: 'android',
        now: () => now);
    await controller.updateIdentity();
  });
  tearDown(() async {
    controller.dispose();
    await store.close();
    await folder.delete(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('innocence/focus_notice'), null);
  });

  test(
      'independent timer survives total focus pause and finish and restores its own clock',
      () async {
    await controller.start(1, 1, true);
    final focus = await store.startFocusSession(owner!,
        endTime: DateTime.now().add(const Duration(minutes: 1)));
    await store.pauseFocusSession(owner!, focus.sessionId);
    await store.finishFocusSession(owner!, focus.sessionId);
    now += 90000;
    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(controller.timer.active, isTrue);
    expect(controller.timer.resting, isTrue);
    expect(controller.timer.remainingSeconds, 30);
    expect(controller.timer.completed, 1);
    await controller.refreshNotices();
    controller.dispose();
    await store.close();
    await store.initialize();
    controller = PomodoroController(
        store: store,
        owner: () => owner,
        chinese: () => true,
        platform: 'android',
        now: () => now);
    await controller.updateIdentity();
    expect(controller.timer.resting, isTrue);
    expect(controller.timer.remainingSeconds, 30);
    expect((await store.loadActiveFocusSession(owner!)).active, isFalse);
  });

  test(
      'pause across many cycles remains frozen, resume catches up, finish clears own notice only',
      () async {
    await controller.start(1, 0, true);
    now += 30500;
    await controller.togglePause();
    final frozen = controller.timer.elapsedMs;
    now += 3600000;
    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(controller.timer.elapsedMs, frozen);
    await controller.togglePause();
    now += 90500;
    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(controller.timer.completed, 2);
    await controller.finish();
    expect(controller.timer.active, isFalse);
    final args = native.last.arguments as Map;
    expect(args['active'], isFalse);
    expect(native.where((call) => call.method == 'sync'), isEmpty);
    expect((await store.loadPomodoro(owner!)).completed, 2);
  });

  test('owner switch cancels previous notice and isolates clocks and settings',
      () async {
    await controller.start(40, 7, true);
    final first = controller.timer.id;
    owner = 'user:999';
    await controller.updateIdentity();
    expect(controller.timer.active, isFalse);
    expect((native.last.arguments as Map)['active'], isFalse);
    await controller.start(10, 0, false);
    expect((native.last.arguments as Map)['active'], isFalse);
    expect((await store.loadPomodoro('local:independent-qa')).id, first);
    owner = null;
    await controller.updateIdentity();
    expect(controller.timer.active, isFalse);
    await controller.start(25, 5, true);
    expect(controller.timer.active, isFalse);
  });

  test(
      'permission denial never loses running timer and invalid durations never persist',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('innocence/focus_notice'),
            (_) async => 'permissionRequired');
    await expectLater(controller.start(0, 5, true), throwsArgumentError);
    expect((await store.loadPomodoro(owner!)).active, isFalse);
    await controller.start(25, 5, true);
    expect(controller.noticeStatus, 'permissionRequired');
    expect(controller.timer.active, isTrue);
  });

  test(
      'v7 migration preserves focus and introduces a separate owner table without sync operations',
      () async {
    final focus = await store.startFocusSession(owner!,
        endTime: DateTime.now().add(const Duration(hours: 1)));
    final db = await databaseFactoryFfi.openDatabase('${folder.path}/qa.db');
    await db.execute('DROP TABLE local_pomodoro_timer');
    await db.setVersion(7);
    await store.close();
    await store.initialize();
    expect((await store.loadActiveFocusSession(owner!)).sessionId,
        focus.sessionId);
    final before = await store.pendingOutboxCount(owner!);
    await store.savePomodoro(owner!, const PomodoroTimer(studyMinutes: 40));
    expect((await store.loadPomodoro(owner!)).studyMinutes, 40);
    expect(await store.pendingOutboxCount(owner!), before);
    expect((await store.loadPomodoro('local:other')).id, isEmpty);
    await expectLater(store.loadPomodoro(''), throwsArgumentError);
    expect(
        () => PomodoroTimer.fromJson({'active': true}), throwsFormatException);
  });

  test(
      'stage math catches up over days without loops and preserves fractional pause time',
      () {
    const t = PomodoroTimer(
        id: 'math',
        active: true,
        studyMinutes: 1,
        breakMinutes: 1,
        referenceMs: 1000);
    expect(t.advance(61000).resting, isTrue);
    expect(t.advance(121000).cycle, 2);
    expect(t.advance(121000).completed, 1);
    expect(t.advance(121000).remainingSeconds, 60);
    expect(t.advance(86401000).completed, 720);
    expect(t.advance(500), same(t));
    expect(t.copy(paused: true).advance(999999), isNotNull);
  });

  for (final theme in AppVisualTheme.values) {
    for (final width in [320.0, 900.0]) {
      testWidgets(
          'independent tab ${theme.name} $width starts without focus and retains controls when focus ends',
          (tester) async {
        tester.view.physicalSize = Size(width, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final capture = GlobalKey();
        Widget fixture(FocusSession focus) => MaterialApp(
            theme: AppVisualTokens.of(theme).toThemeData(theme).copyWith(
                textTheme: AppVisualTokens.of(theme)
                    .toThemeData(theme)
                    .textTheme
                    .apply(fontFamily: 'PomodoroQa')),
            home: Scaffold(
                body: MediaQuery(
                    data: MediaQueryData(
                        textScaler: TextScaler.linear(width == 320 ? 1.5 : 1)),
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: captureWidget(
                            capture,
                            FocusSessionTabs(
                                session: focus,
                                isChinese: true,
                                isBusy: false,
                                pomodoroController: controller,
                                timer: const Text('TOTAL')))))));
        await tester.pumpWidget(fixture(FocusSession.empty()));
        await tester.tap(find.byKey(const ValueKey('focus-pomodoro-tab')));
        await tester.pump();
        await tester.enterText(
            find.byKey(const ValueKey('independent-study-minutes')), '0');
        await tester.ensureVisible(
            find.byKey(const ValueKey('independent-pomodoro-start')));
        await tester
            .tap(find.byKey(const ValueKey('independent-pomodoro-start')));
        await tester.pump();
        expect(find.text('请输入范围内的整数'), findsOneWidget);
        await tester.enterText(
            find.byKey(const ValueKey('independent-study-minutes')), '1');
        expect(tester.state<FormState>(find.byType(Form)).validate(), isTrue);
        await tester.pump();
        await tester.runAsync(() => controller.start(1, 1, false));
        await tester.pump();
        expect(find.byKey(const ValueKey('independent-pomodoro-pause')),
            findsOneWidget);
        await tester.runAsync(controller.togglePause);
        await tester.pumpWidget(fixture(FocusSession.empty()));
        expect(find.text('继续'), findsOneWidget);
        await tester.runAsync(controller.togglePause);
        now += 65000;
        await tester.runAsync(() async {
          controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
          await controller.refreshNotices();
        });
        await tester.pump();
        expect(find.text('休息'), findsOneWidget);
        await tester
            .ensureVisible(find.byKey(const ValueKey('focus-pomodoro-tab')));
        await tester.pump();
        await tester.runAsync(() async {
          final image = await (capture.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final output = Directory('build/qa/independent-pomodoro');
          await output.create(recursive: true);
          await File('${output.path}/${theme.name}-${width.toInt()}.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.runAsync(controller.finish);
        await tester.pump();
        expect(find.byKey(const ValueKey('independent-pomodoro-start')),
            findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}

Widget captureWidget(GlobalKey key, Widget child) =>
    RepaintBoundary(key: key, child: child);
