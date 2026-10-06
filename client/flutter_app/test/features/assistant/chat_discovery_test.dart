import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/features/assistant/data/chat_discovery.dart';
import 'package:innocence_flutter/features/assistant/data/chat_provider.dart';
import 'package:innocence_flutter/features/assistant/application/chat_controller.dart';
import 'chat_assistant_test.dart'
    show
        MemoryChatRepository,
        FixtureToolHost,
        FixtureChatProvider,
        fixtureConnection,
        toolReply;

const fixtureKey = 'fixture-discovery-key';
const okChat = {
  'choices': [
    {
      'finish_reason': 'stop',
      'message': {'role': 'assistant', 'content': 'OK'}
    }
  ]
};

class FixtureApi {
  FixtureApi(this.server);
  final HttpServer server;
  final requests = <Map<String, dynamic>>[];
  String get address => 'http://127.0.0.1:${server.port}';
  static Future<FixtureApi> start(
      FutureOr<(int, Object)> Function(Map<String, dynamic>) respond) async {
    final api =
        FixtureApi(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));
    api.server.listen((request) async {
      final raw = await utf8.decoder.bind(request).join();
      final record = <String, dynamic>{
        'path': request.uri.path,
        'method': request.method,
        'auth': request.headers.value(HttpHeaders.authorizationHeader),
        'body': raw.isEmpty ? null : jsonDecode(raw)
      };
      api.requests.add(record);
      final (status, body) = await respond(record);
      request.response.statusCode = status;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(body));
      try {
        await request.response.close();
      } on SocketException {/* Cancelled client. */}
    });
    return api;
  }

  Future<void> close() => server.close(force: true);
}

class DelayedCatalogProvider extends ChatProvider {
  final result = Completer<ChatModelCatalog>();
  @override
  Future<ChatModelCatalog> discoverModels(String address, String key) =>
      result.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previous = HttpOverrides.current;
  setUpAll(() => HttpOverrides.global = null);
  tearDownAll(() => HttpOverrides.global = previous);
  test('base, v1, full endpoints and custom prefixes preserve one origin', () {
    for (final path in [
      '',
      '/v1',
      '/gateway/v1',
      '/responses',
      '/chat/completions',
      '/v1/models',
      '/gateway/v1/responses/'
    ]) {
      final location = ChatServiceAddress.parse('https://example.test$path');
      expect(
          location.candidates.every((u) => u.origin == 'https://example.test'),
          true);
      expect(ChatServiceAddress.endpoint(location.base, 'responses').path,
          isNot(contains('/responses/responses')));
    }
    expect(
        ChatServiceAddress.parse('https://api.openai.com')
            .candidates
            .first
            .path,
        '/v1');
    expect(
        ChatServiceAddress.parse('https://example.test/v1').candidates.length,
        1);
    for (final bad in [
      'http://example.test',
      'https://key@example.test',
      'https://example.test?key=fixture',
      'https://example.test#fragment'
    ]) {
      expect(() => ChatServiceAddress.parse(bad), throwsFormatException);
    }
  });
  test(
      'catalog preserves actual IDs/order, deduplicates and rejects invalid fields',
      () {
    final uri = Uri.parse('https://example.test');
    final catalog = ChatModelCatalog.parse(
        uri,
        {
          'data': [
            {'id': 'provider/new-model', 'name': 'New model'},
            {'id': 'unknown-model'},
            {'id': 'provider/new-model'}
          ]
        },
        fixtureKey);
    expect(catalog.models.map((m) => m.id),
        ['provider/new-model', 'unknown-model']);
    expect(catalog.models.first.label, 'New model · provider/new-model');
    for (final data in [
      {'data': []},
      {
        'data': [{}]
      },
      {
        'data': [
          {'id': 2}
        ]
      },
      {
        'data': [
          {'id': fixtureKey}
        ]
      },
      {
        'data': [
          {'id': 'bad\nmodel'}
        ]
      },
      {}
    ]) {
      expect(() => ChatModelCatalog.parse(uri, data, fixtureKey),
          throwsFormatException);
    }
  });
  test('real GET discovery falls back to v1 and authenticates only same origin',
      () async {
    final api = await FixtureApi.start((r) => r['path'] == '/models'
        ? (404, {})
        : (
            200,
            {
              'data': [
                {'id': 'discovered'}
              ]
            }
          ));
    final provider = ChatProvider();
    try {
      final catalog = await provider.discoverModels(api.address, fixtureKey);
      expect(catalog.base.path, '/v1');
      expect(catalog.models.single.id, 'discovered');
      expect(api.requests.map((r) => r['path']), ['/models', '/v1/models']);
      expect(
          api.requests.every((r) =>
              r['method'] == 'GET' &&
              r['auth'] == 'Bearer $fixtureKey' &&
              r['body'] == null),
          true);
    } finally {
      provider.cancel();
      await api.close();
    }
  });
  test(
      'discovery credential/quota/redirect failures do not retry or expose bodies',
      () async {
    var status = 401;
    final api =
        await FixtureApi.start((_) => (status, {'message': 'private-error'}));
    final provider = ChatProvider();
    try {
      for (final value in [401, 403, 402, 429, 302, 500]) {
        status = value;
        final before = api.requests.length;
        await expectLater(
            provider.discoverModels(api.address, fixtureKey),
            throwsA(isA<FormatException>().having((e) => e.message, 'sanitized',
                isNot(contains('private-error')))));
        expect(api.requests.length, before + 1);
      }
    } finally {
      provider.cancel();
      await api.close();
    }
  });
  test(
      'empty or missing model IDs fail without a guessed list or extra request',
      () async {
    var data = <String, dynamic>{'data': <Object>[]};
    final api = await FixtureApi.start((_) => (200, data));
    final provider = ChatProvider();
    try {
      for (final value in [
        {'data': <Object>[]},
        {
          'data': [<String, dynamic>{}]
        }
      ]) {
        data = value;
        final before = api.requests.length;
        await expectLater(provider.discoverModels(api.address, fixtureKey),
            throwsFormatException);
        expect(api.requests.length, before + 1);
      }
    } finally {
      provider.cancel();
      await api.close();
    }
  });
  test('automatic connection probes chat then Responses without software data',
      () async {
    final api =
        await FixtureApi.start((r) => r['path'] == '/v1/chat/completions'
            ? (400, {})
            : (
                200,
                {
                  'status': 'completed',
                  'output': [
                    {
                      'type': 'message',
                      'role': 'assistant',
                      'content': [
                        {'type': 'output_text', 'text': 'OK'}
                      ]
                    }
                  ]
                }
              ));
    final provider = ChatProvider();
    try {
      final config = await provider.resolveConnection(
          '${api.address}/v1', fixtureKey, 'actual-model');
      expect(config.protocol, 'responses');
      expect(config.endpoint, '${api.address}/v1/responses');
      expect(api.requests.length, 2);
      expect(
          api.requests.every((r) =>
              (r['body'] as Map)['model'] == 'actual-model' &&
              !(r['body'] as Map).containsKey('tools')),
          true);
    } finally {
      provider.cancel();
      await api.close();
    }
  });
  test('explicit protocol does not silently select another protocol', () async {
    final api = await FixtureApi.start((_) => (200, okChat));
    final provider = ChatProvider();
    try {
      final config = await provider.resolveConnection(
          '${api.address}/v1', fixtureKey, 'chosen',
          protocol: 'chat');
      expect(config.protocol, 'chat');
      expect(api.requests.single['path'], '/v1/chat/completions');
    } finally {
      provider.cancel();
      await api.close();
    }
  });
  test(
      'failed connection preserves previous encrypted repository configuration',
      () async {
    final api =
        await FixtureApi.start((_) => (401, {'message': 'private-error'}));
    final identity = ValueNotifier('a'), repository = MemoryChatRepository();
    final controller = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: FixtureToolHost(),
        repository: repository,
        offlineOnly: false);
    try {
      await controller.configure(fixtureConnection);
      expect(
          await controller.connectService(
              '${api.address}/v1', fixtureKey, 'new'),
          false);
      expect(repository.settings['a'], same(fixtureConnection));
      expect(controller.connection, same(fixtureConnection));
      expect(api.requests.length, 1);
      expect(controller.error, isNot(contains('private-error')));
    } finally {
      controller.dispose();
      identity.dispose();
      await api.close();
    }
  });
  test('late catalog after identity change is discarded without persistence',
      () async {
    final provider = DelayedCatalogProvider(), identity = ValueNotifier('a');
    final repository = MemoryChatRepository();
    final controller = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: FixtureToolHost(),
        repository: repository,
        provider: provider,
        offlineOnly: false);
    final request =
        controller.discoverModels('https://example.test', fixtureKey);
    identity.value = 'b';
    provider.result.complete(ChatModelCatalog(Uri.parse('https://example.test'),
        const [ChatAvailableModel('model-a')]));
    expect(await request, isNull);
    expect(repository.settings, isEmpty);
    expect(controller.configuring, false);
    controller.dispose();
    identity.dispose();
  });
  test('cancel during connection prevents fallback requests and saving',
      () async {
    final started = Completer<void>(), release = Completer<void>();
    final api = await FixtureApi.start((_) async {
      started.complete();
      await release.future;
      return (400, {});
    });
    final identity = ValueNotifier('a'), repository = MemoryChatRepository();
    final controller = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: FixtureToolHost(),
        repository: repository,
        offlineOnly: false);
    final request =
        controller.connectService('${api.address}/v1', fixtureKey, 'model');
    await started.future;
    controller.stop();
    release.complete();
    expect(await request, false);
    expect(api.requests.length, 1);
    expect(repository.settings, isEmpty);
    controller.dispose();
    identity.dispose();
    await api.close();
  });
  test('offline builds reject model discovery and connecting before network',
      () async {
    final identity = ValueNotifier('a'), repository = MemoryChatRepository();
    final controller = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: FixtureToolHost(),
        repository: repository,
        offlineOnly: true);
    expect(await controller.discoverModels('https://example.test', fixtureKey),
        isNull);
    expect(
        await controller.connectService(
            'https://example.test', fixtureKey, 'model'),
        false);
    expect(controller.error, contains('离线'));
    expect(repository.settings, isEmpty);
    controller.dispose();
    identity.dispose();
  });
  test('chat mode rejects unsolicited software calls from a provider',
      () async {
    final identity = ValueNotifier('a'),
        host = FixtureToolHost(),
        provider = FixtureChatProvider()..replies.add(toolReply());
    final controller = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: host,
        repository: MemoryChatRepository(),
        provider: provider,
        offlineOnly: false);
    await controller.configure(fixtureConnection);
    controller.setAgentMode(false);
    await controller.send('Synthetic chat');
    expect(host.writes, 0);
    expect(controller.pending, isNull);
    expect(controller.error, contains('聊天模式'));
    controller.dispose();
    identity.dispose();
  });
}
