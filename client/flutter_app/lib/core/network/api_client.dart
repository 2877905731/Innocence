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
        throw const ApiException('The server returned unreadable data.');
      }

      final apiCode = payload['code'] as int? ?? -1;
      final message = payload['message'] as String? ?? 'Request failed.';

      if (response.statusCode < 200 || response.statusCode >= 300 || apiCode != 0) {
        throw ApiException(
          message,
          code: apiCode,
          statusCode: response.statusCode,
        );
      }

      return payload['data'];
    } on SocketException {
      throw const ApiException('Unable to connect to the server.');
    } on HandshakeException {
      throw const ApiException('Failed to establish a trusted connection.');
    } on FormatException {
      throw const ApiException('The server response format is invalid.');
    } on HttpException catch (error) {
      throw ApiException(error.message);
    }
  }
}
