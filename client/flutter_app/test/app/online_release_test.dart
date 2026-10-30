import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/network/api_client.dart';

void main() {
  test('configured online release resolves the HTTPS app contract', () {
    const configured = String.fromEnvironment('INNOCENCE_API_BASE_URL');
    if (configured.isEmpty || AppConfig.offlineOnlyBuild) return;
    final endpoint = Uri.parse(AppConfig.apiBaseUrl);
    expect(endpoint.scheme, 'https');
    expect(endpoint.path, '/api/app/v1/');
    expect(endpoint.userInfo, isEmpty);
    expect(endpoint.host, isNot(anyOf('localhost', '127.0.0.1', '10.0.2.2')));
  });

  test('enabled transport preserves auth identity and JSON business values',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final requests = <String>[];
    server.listen((request) async {
      requests.add(request.uri.path);
      expect(request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer synthetic-online-token');
      expect(request.headers.value('X-Device-Type'), 'android');
      final body = jsonDecode(await utf8.decoder.bind(request).join());
      expect(body, {'title': '联网合成计划', 'durationMinutes': 25});
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'code': 0,
        'data': {'saved': true, 'durationMinutes': 25}
      }));
      await request.response.close();
    });
    final http = HttpClient();
    addTearDown(() async {
      http.close(force: true);
      await server.close(force: true);
    });
    final client = ApiClient(
        httpClient: http,
        offlineOnly: false,
        baseUrl: 'http://127.0.0.1:${server.port}/api/app/v1/');
    final result = await client.post('fixture-plan', headers: {
      HttpHeaders.authorizationHeader: 'Bearer synthetic-online-token',
      'X-Device-Type': 'android',
    }, body: {
      'title': '联网合成计划',
      'durationMinutes': 25
    });
    expect(result, {'saved': true, 'durationMinutes': 25});
    expect(requests, ['/api/app/v1/fixture-plan']);
  });
}
