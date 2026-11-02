import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/session_controller.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/features/auth/data/auth_api.dart';
import 'package:innocence_flutter/features/auth/data/auth_local_storage.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/checkin/data/check_in_api.dart';
import 'package:innocence_flutter/features/focus/data/focus_session_api.dart';
import 'package:innocence_flutter/features/friends/data/friend_api.dart';
import 'package:innocence_flutter/features/memos/data/memo_api.dart';
import 'package:innocence_flutter/features/notifications/data/notification_api.dart';
import 'package:innocence_flutter/features/plans/data/study_plan_api.dart';
import 'package:innocence_flutter/features/settings/data/settings_api.dart';
import 'package:innocence_flutter/features/stats/data/stats_api.dart';
import 'package:innocence_flutter/features/team/data/team_api.dart';
import 'package:innocence_flutter/features/assistant/application/chat_tools.dart';
import 'package:innocence_flutter/features/assistant/data/chat_provider.dart';

/// Exercises the real tool -> SessionController -> StudyPlanApi -> TCP mapping.
/// The loopback service owns only synthetic records; backend MySQL coverage is separate.
class _AwaitableStore extends OfflineStore {
  _AwaitableStore(String path)
      : super(
            databaseFactory: databaseFactoryFfi,
            databasePathProvider: () async => path);
  Future<void>? _closing;
  @override
  Future<void> close() => _closing ??= super.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previous = HttpOverrides.current;
  setUpAll(() {
    HttpOverrides.global = null;
    sqfliteFfiInit();
  });
  tearDownAll(() => HttpOverrides.global = previous);
  late HttpServer server;
  late HttpClient client;
  late SessionController session;
  late OfflineStore store;
  late Directory folder;
  late Map<int, List<Map<String, dynamic>>> records;
  late List<Map<String, dynamic>> writes;
  int? failure;
  var nextId = 2;

  setUp(() async {
    failure = null;
    nextId = 2;
    writes = [];
    records = {
      2026: [
        {
          'id': '1',
          'clientEntityId': '11111111-1111-4111-8111-111111111111',
          'year': 2026,
          'title': 'Existing',
          'startMonth': 1,
          'endMonth': 8,
          'progressPercent': 70,
          'note': '',
          'colorKey': 'accent',
          'sortOrder': 0,
          'revision': 2,
          'updateTime': '',
          'subtasks': [
            {
              'id': '11',
              'title': 'Existing child',
              'detail': '',
              'completed': true,
              'sortOrder': 0
            }
          ]
        }
      ],
      2027: []
    };
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final path = request.uri.path.replaceFirst('/api/app/v1/', '');
      final trace = request.headers.value('X-Request-ID') ?? 'loopback-request';
      var status = 200, code = 0, message = 'ok';
      dynamic data = <String, dynamic>{
        'userId': 7,
        'userNo': 'isolated-user',
        'items': <dynamic>[]
      };
      if (path == 'plans/year') {
        final year = int.parse(request.uri.queryParameters['year']!);
        data = {'year': year, 'segments': records[year] ?? [], 'months': []};
      } else if (path.startsWith('plans/annual-segments')) {
        final raw = await utf8.decoder.bind(request).join();
        final body = raw.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(raw) as Map<String, dynamic>;
        writes.add({
          'method': request.method,
          'path': path,
          'body': body,
          'requestId': trace,
          'entityHeader': request.headers.value('X-Client-Entity-ID'),
          'device': request.headers.value('X-Device-Type')
        });
        if (failure != null) {
          status = failure!;
          code = status == 403
              ? 2001
              : status == 401
                  ? 2000
                  : 4004;
          message = 'synthetic annual write rejected';
          data = null;
        } else if (request.method == 'PUT' &&
            int.tryParse(path.split('/').last) == null) {
          status = 400;
          code = 1001;
          message = 'invalid numeric segment ID';
          data = null;
        } else if (request.method == 'POST' || request.method == 'PUT') {
          final year = body['year'] as int;
          final list = records.putIfAbsent(year, () => []);
          final id =
              request.method == 'POST' ? '${nextId++}' : path.split('/').last;
          final index = list.indexWhere((r) => r['id'] == id);
          final row = {
            ...body,
            'id': id,
            'revision': index < 0 ? 1 : (list[index]['revision'] as int) + 1,
            'updateTime': DateTime.now().toIso8601String()
          };
          if (index < 0) {
            list.add(row);
          } else {
            list[index] = row;
          }
          data = {'year': year, 'segments': list, 'months': []};
        } else if (request.method == 'DELETE') {
          final id = path.split('/').last;
          for (final list in records.values) {
            list.removeWhere((r) => r['id'] == id);
          }
          data = true;
        }
      } else if (path == 'plans/day-templates') {
        data = [];
      } else if (path.startsWith('settings')) {
        data = {
          'accountSetting': {
            'userId': 7,
            'userNo': 'isolated-user',
            'timezone': 'Asia/Shanghai'
          }
        };
      }
      request.response.statusCode = status;
      request.response.headers.contentType = ContentType.json;
      request.response.headers.set('X-Request-ID', trace);
      request.response.write(jsonEncode({
        'code': code,
        'message': message,
        'data': data,
        'requestId': trace
      }));
      await request.response.close();
    });
    folder = await Directory.systemTemp.createTemp('annual-tool-http-');
    store = _AwaitableStore('${folder.path}/qa.db');
    await store.initialize();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance(),
        local = AuthLocalStorage(prefs);
    await local.saveSession(const AppSession(
        accessToken: 'isolated-fixture-token',
        tokenType: 'Bearer',
        userId: 7,
        deviceType: 'harmonyos',
        deviceSlot: 'tablet',
        deviceId: 'isolated-fixture'));
    client = HttpClient();
    final api = ApiClient(
        httpClient: client,
        offlineOnly: false,
        baseUrl: 'http://127.0.0.1:${server.port}/api/app/v1/');
    session = SessionController(
        authApi: AuthApi(apiClient: api),
        localStorage: local,
        languageController: AppLanguageController(prefs),
        offlineStore: store,
        studyPlanApi: StudyPlanApi(apiClient: api),
        focusSessionApi: FocusSessionApi(apiClient: api),
        checkInApi: CheckInApi(apiClient: api),
        statsApi: StatsApi(apiClient: api),
        teamApi: TeamApi(apiClient: api),
        friendApi: FriendApi(apiClient: api),
        memoApi: MemoApi(apiClient: api),
        notificationApi: NotificationApi(apiClient: api),
        settingsApi: SettingsApi(apiClient: api),
        restoreOfflineOnStartup: false,
        offlineOnlyBuild: false);
    await session.initialize();
    expect(session.status, SessionStatus.authenticated,
        reason: session.bannerMessage);
  });
  tearDown(() async {
    await session.chat.flushDraft();
    session.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    client.close(force: true);
    await server.close(force: true);
    await store.close();
    await folder.delete(recursive: true);
  });
  Map<String, dynamic> minimal(int year) => {
        'year': year,
        'title': 'x',
        'startMonth': 1,
        'endMonth': 1,
        'note': '',
        'subtasks': <String>[]
      };
  Future<Map<String, dynamic>> run(Map<String, dynamic> args) async =>
      (await session.assistantTools
              .prepare(ChatToolCall('annual-call', 'save_annual_task', args)))
          .execute();

  test(
      'minimal create without ID is POST, returns real ID and leaves existing progress unchanged',
      () async {
    final result = await run(minimal(2027));
    expect(result['ok'], true);
    expect(result['id'], '2');
    expect(writes.single['method'], 'POST');
    expect(writes.single['path'], 'plans/annual-segments');
    expect((writes.single['body'] as Map)['progressPercent'], 0);
    expect((writes.single['body'] as Map)['subtasks'], isEmpty);
    expect(writes.single['entityHeader'], result['clientEntityId']);
    expect(writes.single['requestId'], result['requestId']);
    expect(writes.single['device'], 'harmonyos');
    expect(records[2026]!.single['progressPercent'], 70);
  });

  test(
      'explicit empty ID and string subtasks are mapped into structured children on create',
      () async {
    final result = await run({
      ...minimal(2026),
      'id': '',
      'subtasks': ['Read', 'Practice']
    });
    expect(result['ok'], true);
    expect(writes.single['method'], 'POST');
    final children = (writes.single['body'] as Map)['subtasks'] as List;
    expect(children.map((c) => c['title']).toList(), ['Read', 'Practice']);
    expect(children.every((c) => c['completed'] == false), true);
    expect(records[2026], hasLength(2));
  });

  test(
      'editing uses the actual server ID and preserves 70 percent and completed children',
      () async {
    final result = await run({
      ...minimal(2026),
      'id': '1',
      'title': 'Revised',
      'startMonth': 2,
      'endMonth': 9
    });
    expect(result['ok'], true);
    expect(writes.single['method'], 'PUT');
    expect(writes.single['path'], 'plans/annual-segments/1');
    expect(records[2026]!.single['progressPercent'], 70);
    expect(
        (records[2026]!.single['subtasks'] as List).single['completed'], true);
  });

  for (final status in [401, 403, 404]) {
    test(
        'annual HTTP $status survives the Session boolean wrapper as a diagnostic result',
        () async {
      failure = status;
      try {
        await run(minimal(2027));
        fail('Expected a diagnostic failure');
      } on ChatToolFailure catch (error) {
        final result = error.toJson();
        expect(result['ok'], false);
        expect(result['statusCode'], status);
        expect(
            result['errorCode'],
            status == 403
                ? 2001
                : status == 401
                    ? 2000
                    : 4004);
        expect(result['message'], 'synthetic annual write rejected');
        expect(result['requestId'], writes.single['requestId']);
        expect(result['clientEntityId'],
            (writes.single['body'] as Map)['clientEntityId']);
      }
      expect(records[2027], isEmpty);
    });
  }
}
