import 'dart:convert';
import 'dart:io';

import 'package:innocence_flutter/core/config/app_config.dart';

import 'api_exception.dart';

class ApiClient {
  ApiClient({
    HttpClient? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? HttpClient(),
        _baseUri = Uri.parse(baseUrl ?? AppConfig.apiBaseUrl);

  final HttpClient _httpClient;
  final Uri _baseUri;

  Future<dynamic> get(
    String path, {
    Map<String, String> headers = const {},
  }) {
    return _send(
      'GET',
      path,
      headers: headers,
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const {},
  }) {
    return _send(
      'POST',
      path,
      body: body,
      headers: headers,
    );
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const {},
  }) {
    return _send(
      'PUT',
      path,
      body: body,
      headers: headers,
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const {},
  }) {
    return _send(
      'DELETE',
      path,
      body: body,
      headers: headers,
    );
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const {},
  }) async {
    try {
      final request = await _httpClient.openUrl(
        method,
        _baseUri.resolve(path),
      );
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      headers.forEach(request.headers.set);
      if (body != null) {
        request.headers.set(
          HttpHeaders.contentTypeHeader,
          'application/json; charset=utf-8',
        );
        request.add(utf8.encode(jsonEncode(body)));
      }

      final response = await request.close();
      final rawResponse = await utf8.decoder.bind(response).join();
      final payload =
          rawResponse.isEmpty ? <String, dynamic>{} : jsonDecode(rawResponse);

      if (payload is! Map<String, dynamic>) {
        throw const ApiException('服务器返回了无法识别的数据。');
      }

      final apiCode = payload['code'] as int? ?? -1;
      final message = payload['message'] as String? ?? '请求失败，请稍后重试。';

      if (response.statusCode < 200 || response.statusCode >= 300 || apiCode != 0) {
        throw ApiException(
          message,
          code: apiCode,
          statusCode: response.statusCode,
        );
      }

      return payload['data'];
    } on SocketException {
      throw const ApiException('暂时无法连接本地服务，请先启动后端服务。');
    } on HandshakeException {
      throw const ApiException('建立安全连接失败。');
    } on FormatException {
      throw const ApiException('服务器返回内容格式不正确。');
    } on HttpException catch (error) {
      throw ApiException(error.message);
    }
  }
}
