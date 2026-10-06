import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/features/assistant/application/assistant_controller.dart';
import 'package:innocence_flutter/features/assistant/data/assistant_api.dart';
import 'package:innocence_flutter/features/assistant/domain/assistant_models.dart';
import 'package:innocence_flutter/features/assistant/presentation/assistant_page.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/assistant/domain/local_planner.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';

class LostResponseApi extends AssistantApi {
  final p =
      LocalPlanner().generate(TodayPlan.empty(), 'English 60 min', 36, 44);
  int writes = 0;
  Map<String, dynamic>? saved;
  @override
  Future<Map<String, dynamic>> call(AppSession session, String path,
      {Map<String, dynamic>? body}) async {
    if (path == 'proposals') {
      return {'requestStatus': 'complete', 'proposal': p.toJson()};
    }
    if (path.endsWith('/validate')) {
      return {
        'validationId': assistantId(),
        'proposalRevision': (body!['proposalRevision'] as int) + 1,
        'canExecute': true,
        'conflicts': <String>[],
        'items': body['editedItems']
      };
    }
    if (path.endsWith('/execute')) {
      writes++;
      saved = AssistantExecution(
              body!['operationId'] as String,
              'committed',
              p.planDate,
              1,
              true,
              [
                {
                  'itemId': 88,
                  'title': 'English',
                  'startSlot': 36,
                  'endSlot': 38
                }
              ],
              null)
          .toJson();
      throw TimeoutException('synthetic response loss');
    }
    if (path.startsWith('executions/')) return saved!;
    throw StateError('Unexpected fixture path');
  }
}

class DraftStore extends OfflineStore {
  final records = <String, Map<String, dynamic>>{};
  @override
  Future<Map<String, dynamic>?> loadAssistantRecovery(String owner) async =>
      records[owner];
  @override
  Future<void> saveAssistantRecovery(
      String owner, Map<String, dynamic> data) async {
    records[owner] = data;
  }

  @override
  Future<void> saveAssistantProposal(
      String owner, AssistantProposal proposal) async {}
}

AssistantController fixture(ValueNotifier<String> identity, DraftStore store,
        {Future<TodayPlan?> Function(String)? load}) =>
    AssistantController(
        identity: identity,
        owner: () => identity.value,
        offline: () => true,
        session: () => null,
        loadPlan: load ?? (date) async => TodayPlan.empty(date),
        refresh: (_) async {},
        store: store,
        api: AssistantApi());
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  String? qaFont;
  setUpAll(() async {
    final file = File(r'C:\Windows\Fonts\msyh.ttc');
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      await (FontLoader('AssistantQa')
            ..addFont(Future.value(ByteData.sublistView(bytes))))
          .load();
      qaFont = 'AssistantQa';
    }
    final icons = File(
        r'D:\soft\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf');
    if (await icons.exists()) {
      await (FontLoader('MaterialIcons')
            ..addFont(
                Future.value(ByteData.sublistView(await icons.readAsBytes()))))
          .load();
    }
  });
  for (final theme in [AppVisualTheme.minimalism, AppVisualTheme.glass]) {
    for (final width in [320.0, 820.0, 1280.0]) {
      testWidgets(
          '${theme.name} width $width keeps draft and renders with large text/keyboard',
          (tester) async {
        tester.view.physicalSize = Size(width, 860);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final identity = ValueNotifier('local:fixture');
        final c = fixture(identity, DraftStore());
        c.instruction = '英语 60分钟；数学 60分钟';
        await c.generate();
        final boundary = GlobalKey();
        await tester.pumpWidget(MaterialApp(
            theme: AppVisualTokens.of(theme).toThemeData(theme).copyWith(
                textTheme: AppVisualTokens.of(theme)
                    .toThemeData(theme)
                    .textTheme
                    .apply(fontFamily: qaFont)),
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.5),
                    viewInsets: width == 320
                        ? const EdgeInsets.only(bottom: 280)
                        : EdgeInsets.zero,
                    disableAnimations: true),
                child: child!),
            home: RepaintBoundary(
                key: boundary,
                child: AssistantPage(
                    controller: c,
                    language: AppLanguage.simplifiedChinese,
                    visualTheme: theme))));
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
        final selected = c.selectedId;
        tester.view.physicalSize = Size(width == 1280 ? 820 : 1280, 860);
        await tester.pump(const Duration(milliseconds: 300));
        expect(c.selectedId, selected);
        expect(c.instruction, '英语 60分钟；数学 60分钟');
        expect(tester.takeException(), isNull);
        tester.view.physicalSize = Size(width, 860);
        await tester.pump(const Duration(milliseconds: 300));
        // Host-rendered artifacts are layout evidence only; device rendering remains a separate gate.
        await tester.runAsync(() async {
          final render = boundary.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
          final image = await render.toImage(pixelRatio: 1);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          final dir = Directory('build/qa/assistant');
          await dir.create(recursive: true);
          await File('${dir.path}/${theme.name}-${width.toInt()}.png')
              .writeAsBytes(png!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        c.dispose();
        identity.dispose();
      });
    }
  }
  test('identity switch discards a late planning snapshot', () async {
    final identity = ValueNotifier('local:first'), store = DraftStore();
    final pending = Completer<TodayPlan?>();
    final c = fixture(identity, store, load: (_) => pending.future);
    c.instruction = 'English 60 min';
    final operation = c.generate();
    identity.value = 'local:second';
    pending.complete(TodayPlan.empty());
    await operation;
    expect(c.proposal, isNull);
    expect(c.instruction, '');
    expect(c.busy, false);
    expect(store.records['local:second'], isNull);
    c.dispose();
    identity.dispose();
  });
  test('draft recovery stays within its owner scope', () async {
    final identity = ValueNotifier('local:first'), store = DraftStore();
    var c = fixture(identity, store);
    c.instruction = 'English 60 min';
    await c.generate();
    final id = c.proposal!.id;
    await c.saveDraft();
    c.dispose();
    c = fixture(identity, store);
    await c.restore();
    expect(c.proposal!.id, id);
    expect(c.instruction, 'English 60 min');
    identity.value = 'local:second';
    await c.restore();
    expect(c.proposal, isNull);
    expect(c.instruction, '');
    c.dispose();
    identity.dispose();
  });
  test(
      'lost execution response survives restart and resolves without another write',
      () async {
    final identity = ValueNotifier('user:fixture'),
        store = DraftStore(),
        api = LostResponseApi();
    const session = AppSession(
        accessToken: 'synthetic-session',
        tokenType: 'Bearer',
        userId: 42,
        deviceType: 'windows',
        deviceSlot: 'desktop',
        deviceId: 'fixture');
    AssistantController create() => AssistantController(
        identity: identity,
        owner: () => identity.value,
        offline: () => false,
        session: () => session,
        loadPlan: (date) async => TodayPlan.empty(date),
        refresh: (_) async {},
        store: store,
        api: api);
    var c = create();
    c.instruction = 'English 60 min';
    await c.generate();
    await c.validate();
    await c.apply();
    final pending = c.pendingOperationId;
    expect(pending, isNotNull);
    expect(api.writes, 1);
    c.dispose();
    c = create();
    await c.restore();
    expect(c.pendingOperationId, pending);
    await c.resolve();
    expect(c.execution!.status, 'committed');
    expect(c.pendingOperationId, isNull);
    expect(api.writes, 1);
    c.dispose();
    identity.dispose();
  });
}
