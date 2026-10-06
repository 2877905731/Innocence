import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/session_controller.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/features/auth/data/auth_api.dart';
import 'package:innocence_flutter/features/auth/data/auth_local_storage.dart';
import 'package:innocence_flutter/features/assistant/application/chat_controller.dart';
import 'package:innocence_flutter/features/assistant/application/chat_tools.dart';
import 'package:innocence_flutter/features/assistant/data/chat_provider.dart';
import 'package:innocence_flutter/features/assistant/data/chat_discovery.dart';
import 'package:innocence_flutter/features/assistant/data/chat_repository.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';

const fixtureConnection = ChatConnection(
    endpoint: 'http://127.0.0.1:9999/chat',
    model: 'fixture',
    apiKey: 'fixture-key-only');

class MemoryChatRepository implements ChatRepository {
  final settings = <String, ChatConnection>{};
  final history = <String, List<Map<String, dynamic>>>{};
  @override
  Future<ChatConnection?> loadConnection(String owner) async => settings[owner];
  @override
  Future<void> saveConnection(String owner, ChatConnection value) async {
    settings[owner] = value;
  }

  @override
  Future<void> deleteConnection(String owner) async {
    settings.remove(owner);
  }

  @override
  Future<List<Map<String, dynamic>>> loadHistory(String owner) async =>
      history[owner] ?? [];
  @override
  Future<void> saveHistory(
      String owner, List<Map<String, dynamic>> messages) async {
    history[owner] = messages;
  }
}

class FixtureChatProvider extends ChatProvider {
  ChatModelCatalog? catalog;
  @override
  Future<ChatModelCatalog> discoverModels(String address, String apiKey) async {
    ChatConnection.validateKey(apiKey);
    return catalog ?? (throw const FormatException('fixture has no catalog'));
  }

  final replies = <ChatReply>[];
  final requests = <List<Map<String, dynamic>>>[];
  final tools = <List<Map<String, dynamic>>>[];
  Completer<ChatReply>? delayed;
  @override
  Future<ChatReply> complete(
      ChatConnection connection,
      List<Map<String, dynamic>> messages,
      List<Map<String, dynamic>> definitions) async {
    requests.add(messages);
    tools.add(definitions);
    if (delayed != null) return delayed!.future;
    return replies.removeAt(0);
  }
}

class FixtureToolHost extends ChatToolHost {
  int writes = 0;
  @override
  List<Map<String, dynamic>> get definitions =>
      [chatTool('write', 'fixture', {})];
  @override
  Future<PreparedChatTool> prepare(ChatToolCall call) async => PreparedChatTool(
      summary: 'synthetic write',
      confirm: true,
      execute: () async {
        writes++;
        return {'ok': true};
      });
}

ChatReply textReply(String text) =>
    ChatReply(text, [], {'role': 'assistant', 'content': text});
ChatReply toolReply([String id = 'call-fixture']) => ChatReply('', [
      ChatToolCall(id, 'write', {})
    ], {
      'role': 'assistant',
      'content': null,
      'tool_calls': [
        {
          'id': id,
          'type': 'function',
          'function': {'name': 'write', 'arguments': '{}'}
        }
      ]
    });
Future<void> eventually(bool Function() condition) async {
  for (var i = 0; i < 100 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  expect(condition(), isTrue);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttpOverride = HttpOverrides.current;
  setUpAll(() {
    HttpOverrides.global = null;
  });
  tearDownAll(() {
    HttpOverrides.global = previousHttpOverride;
  });
  test('chat mode keeps multiround context and never provides software tools',
      () async {
    final identity = ValueNotifier<String>('owner-a'),
        host = FixtureToolHost(),
        provider = FixtureChatProvider()
          ..replies.addAll([textReply('first'), textReply('second')]);
    final repo = MemoryChatRepository();
    final c = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: host,
        repository: repo,
        provider: provider,
        offlineOnly: false);
    await c.configure(fixtureConnection);
    c.setAgentMode(false);
    await c.send('hello');
    await c.send('continue');
    expect(provider.tools.every((t) => t.isEmpty), isTrue);
    expect(provider.requests.last.any((m) => m['content'] == 'first'), isTrue);
    expect(host.writes, 0);
    expect(repo.history['owner-a']!.length, 4);
    c.dispose();
    identity.dispose();
  });
  test(
      'write requires a decision; decline is returned to model; approved executes once',
      () async {
    final identity = ValueNotifier<String>('a'),
        host = FixtureToolHost(),
        provider = FixtureChatProvider()
          ..replies.addAll([
            toolReply(),
            textReply('cancelled'),
            toolReply('second'),
            textReply('saved')
          ]);
    final c = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: host,
        repository: MemoryChatRepository(),
        provider: provider,
        offlineOnly: false);
    await c.configure(fixtureConnection);
    final denied = c.send('write');
    await eventually(() => c.pending != null);
    expect(host.writes, 0);
    c.decide(false);
    await denied;
    expect(host.writes, 0);
    expect(provider.requests[1].last['content'], contains('USER_DECLINED'));
    final accepted = c.send('write');
    await eventually(() => c.pending != null);
    c.decide(true);
    c.decide(true);
    await accepted;
    expect(host.writes, 1);
    c.dispose();
    identity.dispose();
  });
  test('stop while awaiting confirmation does not execute a write', () async {
    final identity = ValueNotifier<String>('a'),
        host = FixtureToolHost(),
        provider = FixtureChatProvider()..replies.add(toolReply());
    final c = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: host,
        repository: MemoryChatRepository(),
        provider: provider,
        offlineOnly: false);
    await c.configure(fixtureConnection);
    final turn = c.send('write');
    await eventually(() => c.pending != null);
    c.stop();
    await turn;
    expect(host.writes, 0);
    expect(c.busy, isFalse);
    expect(c.pending, isNull);
    c.dispose();
    identity.dispose();
  });
  test(
      'identity switch discards late model reply and clears key/history in memory',
      () async {
    final identity = ValueNotifier<String>('a'),
        host = FixtureToolHost(),
        provider = FixtureChatProvider()..delayed = Completer<ChatReply>();
    final repo = MemoryChatRepository();
    final c = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: host,
        repository: repo,
        provider: provider,
        offlineOnly: false);
    await c.configure(fixtureConnection);
    final turn = c.send('hello');
    await eventually(() => provider.requests.isNotEmpty);
    identity.value = 'b';
    provider.delayed!.complete(textReply('private-a'));
    await turn;
    expect(c.entries, isEmpty);
    expect(c.connection, isNull);
    expect(repo.settings['b'], isNull);
    expect(host.writes, 0);
    c.dispose();
    identity.dispose();
  });
  test('offline edition and missing configuration fail before network',
      () async {
    final identity = ValueNotifier<String>('a'),
        provider = FixtureChatProvider();
    final c = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: FixtureToolHost(),
        repository: MemoryChatRepository(),
        provider: provider,
        offlineOnly: true);
    await c.configure(fixtureConnection);
    await c.send('hi');
    expect(provider.requests, isEmpty);
    expect(c.error, contains('离线'));
    c.dispose();
    identity.dispose();
    expect(
        () => const ChatConnection(
                endpoint: 'http://example.com/chat',
                model: 'x',
                apiKey: 'fixture')
            .uri,
        throwsFormatException);
    expect(
        () => const ChatConnection(
                endpoint: 'https://example.com/chat?key=fixture',
                model: 'x',
                apiKey: 'fixture')
            .uri,
        throwsFormatException);
  });
  test(
      'native vault boundary persists ciphertext only, owner scoped, fails closed',
      () async {
    SharedPreferences.setMockInitialValues({});
    const channel = MethodChannel('innocence/assistant_vault');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            channel,
            (call) async => Uint8List.fromList(
                (call.arguments as Uint8List).map((v) => v ^ 171).toList()));
    final repo = NativeChatRepository();
    await repo.saveConnection('a', fixtureConnection);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys().map((k) => prefs.get(k)).join(),
        isNot(contains(fixtureConnection.apiKey)));
    expect((await repo.loadConnection('a'))!.apiKey, fixtureConnection.apiKey);
    expect(await repo.loadConnection('b'), isNull);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await expectLater(repo.saveConnection('b', fixtureConnection),
        throwsA(isA<MissingPluginException>()));
    expect(await repo.loadConnection('b'), isNull);
  });
  test('Chat Completions loopback protocol includes tool IDs and JSON results',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final bodies = <Map>[];
    final subscription = server.listen((r) async {
      expect(r.headers.value('authorization'), 'Bearer fixture-key-only');
      bodies.add(jsonDecode(await utf8.decoder.bind(r).join()) as Map);
      r.response.headers.contentType = ContentType.json;
      r.response.write(jsonEncode({
        'choices': [
          {
            'finish_reason': bodies.length == 1 ? 'tool_calls' : 'stop',
            'message': bodies.length == 1
                ? {
                    'role': 'assistant',
                    'content': null,
                    'reasoning_content': 'fixture reasoning',
                    'tool_calls': [
                      {
                        'id': 'read1',
                        'type': 'function',
                        'function': {'name': 'read', 'arguments': '{}'}
                      }
                    ]
                  }
                : {'role': 'assistant', 'content': 'ready'}
          }
        ]
      }));
      await r.response.close();
    });
    final provider = ChatProvider(),
        config = ChatConnection(
            endpoint: 'http://127.0.0.1:${server.port}/chat',
            model: 'fixture',
            apiKey: 'fixture-key-only');
    final reply = await provider.complete(config, [
      {'role': 'user', 'content': 'read'}
    ], [
      chatTool('read', 'fixture', {})
    ]);
    expect(reply.calls.single.id, 'read1');
    final finalReply = await provider.complete(config, [
      {'role': 'user', 'content': 'read'},
      reply.message,
      {'role': 'tool', 'tool_call_id': 'read1', 'content': '{"ok":true}'}
    ], []);
    expect(finalReply.text, 'ready');
    expect((bodies.last['messages'] as List).last['tool_call_id'], 'read1');
    expect((bodies.last['messages'] as List)[1]['reasoning_content'],
        'fixture reasoning');
    provider.cancel();
    await subscription.cancel();
    await server.close(force: true);
  });
  test(
      'Responses loopback protocol roundtrips function outputs and reasoning items',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final bodies = <Map>[];
    final subscription = server.listen((r) async {
      bodies.add(jsonDecode(await utf8.decoder.bind(r).join()) as Map);
      r.response.headers.contentType = ContentType.json;
      r.response.write(jsonEncode({
        'status': 'completed',
        'output': bodies.length == 1
            ? [
                {'type': 'reasoning', 'id': 'rs_fixture', 'summary': []},
                {
                  'type': 'function_call',
                  'id': 'fc_fixture',
                  'call_id': 'read1',
                  'name': 'read',
                  'arguments': '{}'
                }
              ]
            : [
                {
                  'type': 'message',
                  'role': 'assistant',
                  'content': [
                    {'type': 'output_text', 'text': 'ready'}
                  ]
                }
              ]
      }));
      await r.response.close();
    });
    final provider = ChatProvider(),
        config = ChatConnection(
            endpoint: 'http://127.0.0.1:${server.port}/responses',
            model: 'fixture',
            apiKey: 'fixture-key-only',
            protocol: 'responses');
    final reply = await provider.complete(config, [
      {'role': 'user', 'content': 'read'}
    ], [
      chatTool('read', 'fixture', {})
    ]);
    final done = await provider.complete(config, [
      reply.message,
      {'role': 'tool', 'tool_call_id': 'read1', 'content': '{"ok":true}'}
    ], []);
    expect(done.text, 'ready');
    expect(bodies.last['store'], false);
    expect((bodies.last['input'] as List).last['type'], 'function_call_output');
    expect((bodies.first['tools'] as List).first['name'], 'read');
    provider.cancel();
    await subscription.cancel();
    await server.close(force: true);
  });
  test(
      'provider negative paths do not expose upstream bodies or accept partial calls',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var scenario = 401;
    final subscription = server.listen((r) async {
      await r.drain<void>();
      r.response.statusCode = scenario < 1000 ? scenario : 200;
      r.response.write(scenario < 1000
          ? 'fixture-private-error'
          : jsonEncode({
              'choices': [
                {
                  'finish_reason': scenario == 1001 ? 'length' : 'tool_calls',
                  'message': {
                    'role': 'assistant',
                    'content': null,
                    'tool_calls': [
                      {
                        'id': 'x',
                        'type': 'function',
                        'function': {'name': 'write'}
                      }
                    ]
                  }
                }
              ]
            }));
      await r.response.close();
    });
    final provider = ChatProvider(),
        config = ChatConnection(
            endpoint: 'http://127.0.0.1:${server.port}/chat',
            model: 'fixture',
            apiKey: 'fixture-key-only');
    for (final status in [401, 403, 429, 302, 500, 1001, 1002]) {
      scenario = status;
      await expectLater(
          provider.complete(config, [
            {'role': 'user', 'content': 'test'}
          ], []),
          throwsA(isA<FormatException>().having((e) => e.message, 'sanitized',
              isNot(contains('fixture-private-error')))));
    }
    provider.cancel();
    await subscription.cancel();
    await server.close(force: true);
  });
  test(
      'repeated model write requests in one turn reuse result instead of writing again',
      () async {
    final identity = ValueNotifier<String>('a'),
        host = FixtureToolHost(),
        provider = FixtureChatProvider()
          ..replies
              .addAll([toolReply('one'), toolReply('two'), textReply('done')]);
    final c = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: host,
        repository: MemoryChatRepository(),
        provider: provider,
        offlineOnly: false);
    await c.configure(fixtureConnection);
    final turn = c.send('write');
    await eventually(() => c.pending != null);
    c.decide(true);
    await turn;
    expect(host.writes, 1);
    expect(
        provider.requests.last.last['content'], contains('repeatSuppressed'));
    c.dispose();
    identity.dispose();
  });
  group('real SQLite app tools', () {
    late Directory dir;
    late OfflineStore store;
    late SessionController session;
    late AppLanguageController language;
    setUp(() async {
      sqfliteFfiInit();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      dir = await Directory.systemTemp.createTemp('innocence-chat-tools-');
      store = OfflineStore(
          databaseFactory: databaseFactoryFfi,
          databasePathProvider: () async => '${dir.path}/local.db');
      language = AppLanguageController(prefs);
      session = SessionController(
          authApi: AuthApi(),
          localStorage: AuthLocalStorage(prefs),
          languageController: language,
          offlineStore: store,
          offlineOnlyBuild: false);
      await session.enterOfflineMode();
    });
    tearDown(() async {
      session.dispose();
      language.dispose();
      await store.close();
      expect(dir.absolute.path, startsWith(Directory.systemTemp.absolute.path));
      await dir.delete(recursive: true);
    });
    test(
        'chat additions preserve IDs/status and actual values, write outbox, undo by execution',
        () async {
      final owner = session.localOwnerScope!, date = TodayPlan.empty().planDate;
      await store.saveDailyPlan(
          owner,
          TodayPlan.empty().copyWith(items: [
            const TodayPlanItem(
                id: 17,
                title: 'Original',
                completed: true,
                plannedMinutes: 60,
                actualMinutes: 53,
                startSlot: 10,
                endSlot: 12,
                sortOrder: 0)
          ]));
      final tool = await session.assistantTools
          .prepare(ChatToolCall('add', 'add_day_tasks', {
        'date': date,
        'timeZone': 'Asia/Shanghai',
        'tasks': [
          {'title': 'New', 'startSlot': 20, 'endSlot': 22}
        ]
      }));
      expect(tool.confirm, true);
      final result = await tool.execute();
      expect(result['ok'], true);
      final saved = await store.loadDailyPlan(owner, date);
      expect(saved.items.first.id, 17);
      expect(saved.items.first.completed, true);
      expect(saved.items.first.actualMinutes, 53);
      expect(saved.items.length, 2);
      expect(await store.loadPendingSyncOperations(owner), isNotEmpty);
      final undo = await session.assistantTools.prepare(ChatToolCall('undo',
          'undo_plan_execution', {'executionId': result['executionId']}));
      expect((await undo.execute())['ok'], true);
      expect((await store.loadDailyPlan(owner, date)).items.single.id, 17);
    });
    test(
        'stale confirmation and unknown identity parameters cannot modify plan',
        () async {
      final owner = session.localOwnerScope!, date = TodayPlan.empty().planDate;
      final tool = await session.assistantTools
          .prepare(ChatToolCall('add', 'add_day_tasks', {
        'date': date,
        'timeZone': 'Asia/Shanghai',
        'tasks': [
          {'title': 'New', 'startSlot': 20, 'endSlot': 22}
        ]
      }));
      await store.saveDailyPlan(owner, TodayPlan.empty());
      await expectLater(tool.execute(), throwsFormatException);
      await expectLater(
          session.assistantTools.prepare(const ChatToolCall('x',
              'read_software', {'resource': 'day', 'ownerScope': 'other'})),
          throwsFormatException);
      await expectLater(
          session.assistantTools
              .prepare(const ChatToolCall('x', 'cancel_account', {})),
          throwsFormatException);
      expect((await store.loadDailyPlan(owner, date)).items, isEmpty);
    });
    test(
        'stop invalidates prepared software actions and navigation stays in current identity',
        () async {
      final date = TodayPlan.empty().planDate;
      final tool = await session.assistantTools
          .prepare(ChatToolCall('add', 'add_day_tasks', {
        'date': date,
        'timeZone': 'Asia/Shanghai',
        'tasks': [
          {'title': 'New', 'startSlot': 20, 'endSlot': 22}
        ]
      }));
      session.assistantTools.cancel();
      await expectLater(tool.execute(), throwsFormatException);
      String? page;
      session.assistantTools.navigate = (value) async {
        page = value;
      };
      final nav = await session.assistantTools
          .prepare(const ChatToolCall('open', 'open_page', {'page': 'plans'}));
      expect(nav.confirm, false);
      expect((await nav.execute())['ok'], true);
      expect(page, 'plans');
      expect((await store.loadDailyPlan(session.localOwnerScope!, date)).items,
          isEmpty);
    });
    test('failed annual reload rejects stale cached data and writes', () async {
      final year = DateTime.now().year;
      await session.loadAnnualOverview(year);
      final db = await databaseFactoryFfi.openDatabase('${dir.path}/local.db');
      await db.execute('DROP TABLE local_annual_segment');
      final read = await session.assistantTools.prepare(ChatToolCall('read',
          'read_software', {'resource': 'year', 'date': '$year-01-01'}));
      await expectLater(read.execute(), throwsFormatException);
      await expectLater(
          session.assistantTools
              .prepare(ChatToolCall('write', 'save_annual_task', {
            'id': '',
            'year': year,
            'title': 'Synthetic',
            'startMonth': 1,
            'endMonth': 12,
            'note': '',
            'subtasks': <String>[]
          })),
          throwsFormatException);
    });
    test('memos annual subtasks and focus use real app persistence', () async {
      Future<Map<String, dynamic>> run(
              String name, Map<String, dynamic> args) async =>
          (await session.assistantTools
                  .prepare(ChatToolCall('call', name, args)))
              .execute();
      final memo = await run(
          'create_memo', {'title': 'Goals', 'content': 'Synthetic goals'});
      expect(memo['ok'], true);
      final id = memo['memoId'];
      expect(
          (await run('update_memo', {
            'memoId': id,
            'title': 'Updated',
            'content': 'Synthetic update'
          }))['ok'],
          true);
      final annual = await run('save_annual_task', {
        'id': '',
        'year': DateTime.now().year,
        'title': 'Learn',
        'startMonth': 1,
        'endMonth': 12,
        'note': 'Synthetic',
        'subtasks': ['Read', 'Practice']
      });
      expect(annual['ok'], true);
      expect(session.annualPlanOverview.segments.single.subtasks.length, 2);
      expect(session.annualPlanOverview.segments.single.progressPercent, 0);
      expect(
          (await run('control_focus', {
            'action': 'start',
            'minutes': 25,
            'taskName': 'Synthetic focus'
          }))['ok'],
          true);
      expect(
          (await run('control_focus',
              {'action': 'toggle_pause', 'minutes': 0, 'taskName': ''}))['ok'],
          true);
      expect(
          (await run('control_focus',
              {'action': 'finish', 'minutes': 0, 'taskName': ''}))['ok'],
          true);
      expect((await run('delete_memo', {'memoId': id}))['ok'], true);
    });
  });
}
