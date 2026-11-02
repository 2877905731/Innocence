import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:innocence_flutter/core/config/app_config.dart';

import 'api_exception.dart';
import '../utils/request_id.dart';

class ApiClient {
  ApiClient({
    HttpClient? httpClient,
    String? baseUrl,
    bool? offlineOnly,
  })  : _httpClient = httpClient ?? HttpClient(),
        _offlineOnly = offlineOnly ?? AppConfig.offlineOnlyBuild,
        _baseUri = Uri.parse(baseUrl ?? AppConfig.apiBaseUrl);

  final HttpClient _httpClient;
  final Uri _baseUri;
  final bool _offlineOnly;

  void _requireNetworkEnabled() {
    if (_offlineOnly) {
      throw const ApiException(
        '此版本仅支持本机离线使用，联网功能将在后续版本开放。',
        statusCode: 403,
      );
    }
  }

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

  Future<dynamic> postMultipart(
    String path, {
    required String fieldName,
    required List<int> bytes,
    required String filename,
    required String contentType,
    Map<String, String> headers = const {},
  }) async {
    _requireNetworkEnabled();
    try {
      final request = await _httpClient.postUrl(_baseUri.resolve(path));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      headers.forEach(request.headers.set);

      final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
      final nonce = Random.secure().nextInt(1 << 32).toRadixString(16);
      final boundary = 'innocence-$timestamp-$nonce';
      final safeFieldName = _safeMultipartToken(fieldName, fallback: 'file');
      final safeFilename = _safeMultipartToken(filename, fallback: 'avatar');
      final prefix = utf8.encode(
        '--$boundary\r\n'
        'Content-Disposition: form-data; name="$safeFieldName"; filename="$safeFilename"\r\n'
        'Content-Type: $contentType\r\n\r\n',
      );
      final suffix = utf8.encode('\r\n--$boundary--\r\n');

      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );
      request.contentLength = prefix.length + bytes.length + suffix.length;
      request.add(prefix);
      request.add(bytes);
      request.add(suffix);

      return _readResponse(await request.close());
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

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const {},
  }) async {
    _requireNetworkEnabled();
    final requestId = headers.entries
            .where((e) => e.key.toLowerCase() == 'x-request-id')
            .map((e) => e.value)
            .firstOrNull ??
        newRequestId();
    try {
      final request = await _httpClient.openUrl(
        method,
        _baseUri.resolve(path),
      );
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      headers.forEach(request.headers.set);
      request.headers.set('X-Request-ID', requestId);
      if (body != null) {
        request.headers.set(
          HttpHeaders.contentTypeHeader,
          'application/json; charset=utf-8',
        );
        request.add(utf8.encode(jsonEncode(body)));
      }

      return _readResponse(await request.close(), requestId: requestId);
    } on SocketException {
      throw ApiException('暂时无法连接服务，请检查网络。', requestId: requestId);
    } on HandshakeException {
      throw ApiException('建立安全连接失败。', requestId: requestId);
    } on FormatException {
      throw ApiException('服务器返回内容格式不正确。', requestId: requestId);
    } on HttpException catch (error) {
      throw ApiException(error.message, requestId: requestId);
    }
  }

  Future<dynamic> _readResponse(HttpClientResponse response,
      {String? requestId}) async {
    final rawResponse = await utf8.decoder.bind(response).join();
    final payload =
        rawResponse.isEmpty ? <String, dynamic>{} : jsonDecode(rawResponse);

    if (payload is! Map<String, dynamic>) {
      throw const ApiException('服务器返回了无法识别的数据。');
    }

    final apiCode = payload['code'] as int? ?? -1;
    final message = payload['message'] as String? ?? '请求失败，请稍后重试。';

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        apiCode != 0) {
      throw ApiException(
        message,
        code: apiCode,
        statusCode: response.statusCode,
        requestId: (payload['requestId'] is String &&
                (payload['requestId'] as String).isNotEmpty)
            ? payload['requestId'] as String
            : response.headers.value('X-Request-ID') ?? requestId,
      );
    }

    return payload['data'];
  }

  String _safeMultipartToken(String value, {required String fallback}) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return sanitized.isEmpty ? fallback : sanitized;
  }
}
