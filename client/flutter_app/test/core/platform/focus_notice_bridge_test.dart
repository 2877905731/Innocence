import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/core/platform/focus_notice_bridge.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('innocence/focus_notice');
  final calls = <MethodCall>[];
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return call.method == 'sync' ? 'available' : null;
    });
  });
  tearDown(() => TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));
  FocusSession focus({bool paused = false}) => FocusSession.fromJson({
        'sessionId': 7,
        'active': true,
        'paused': paused,
        'remainingSeconds': 90,
      });

  test('system deadline stays fixed instead of republishing every second',
      () async {
    final bridge = FocusNoticeBridge(platform: 'android');
    final running = focus();
    await bridge.sync(
        session: running, owner: 'local:fixture', isChinese: true);
    await bridge.sync(
        session: running.tick(), owner: 'local:fixture', isChinese: true);
    expect(calls, hasLength(1));
    expect(calls.single.arguments['deadlineMs'],
        running.referenceTime.millisecondsSinceEpoch + 90000);
    expect(calls.single.arguments.containsKey('taskName'), isFalse);
    await bridge.sync(
        session: focus(paused: true), owner: 'local:fixture', isChinese: true);
    expect(calls.last.arguments['paused'], isTrue);
  });

  test(
      'late start finishes before logout cancellation without crossing identity',
      () async {
    final gate = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (calls.length == 1) await gate.future;
      return 'available';
    });
    final bridge = FocusNoticeBridge(platform: 'android');
    final start =
        bridge.sync(session: focus(), owner: 'user:fixture', isChinese: true);
    await Future<void>.delayed(Duration.zero);
    final logout = bridge.sync(
        session: FocusSession.empty(), owner: null, isChinese: true);
    expect(calls, hasLength(1));
    gate.complete();
    await Future.wait([start, logout]);
    expect(calls, hasLength(2));
    expect(calls.last.arguments['owner'], isEmpty);
    expect(calls.last.arguments['active'], isFalse);
    expect(calls.last.arguments['completed'], isFalse);
  });

  test('denied permission and unavailable live countdown are surfaced',
      () async {
    for (final pair in {
      'permissionRequired': FocusNoticeStatus.permissionRequired,
      'exactPermissionRequired': FocusNoticeStatus.exactPermissionRequired,
      'liveCountdownUnavailable': FocusNoticeStatus.liveCountdownUnavailable,
    }.entries) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async => pair.key);
      expect(
          await FocusNoticeBridge(platform: 'harmonyos')
              .sync(session: focus(), owner: 'fixture', isChinese: true),
          pair.value);
    }
  });

  test('native failure does not claim notifications are enabled', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            channel, (_) async => throw PlatformException(code: 'failed'));
    expect(
        await FocusNoticeBridge(platform: 'android')
            .sync(session: focus(), owner: 'fixture', isChinese: true),
        FocusNoticeStatus.unavailable);
  });

  test('Windows completion is issued once, even after language change',
      () async {
    const desktop = MethodChannel('innocence/desktop_widget');
    final completed = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(desktop, (call) async {
      completed.add(call);
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(desktop, null));
    final bridge = FocusNoticeBridge(platform: 'windows');
    await bridge.sync(
        session: focus(), owner: 'fixture', isChinese: true, completed: true);
    await bridge.sync(
        session: focus(), owner: 'fixture', isChinese: false, completed: true);
    expect(completed, hasLength(1));
    expect(completed.single.method, 'showFocusCompletion');
  });
}
