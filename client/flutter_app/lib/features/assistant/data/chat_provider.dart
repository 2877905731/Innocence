import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'chat_repository.dart';
import 'chat_discovery.dart';

class ChatToolCall {
  const ChatToolCall(this.id, this.name, this.arguments);
  final String id, name;
  final Map<String, dynamic> arguments;
}

class ChatReply {
  const ChatReply(this.text, this.calls, this.message);
  final String text;
  final List<ChatToolCall> calls;
  final Map<String, dynamic> message;
}

class ChatProvider {
  HttpClient? _active;
  int _generation = 0;
  void cancel() {
    _generation++;
    _active?.close(force: true);
    _active = null;
  }

  Future<ChatModelCatalog> discoverModels(String address, String apiKey) async {
    final location = ChatServiceAddress.parse(address);
    ChatConnection.validateKey(apiKey);
    final generation = _generation;
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    _active = client;
    try {
      return await (() async {
        for (final base in location.candidates) {
          if (generation != _generation) {
            throw const FormatException('连接设置操作已取消。');
          }
          final request =
              await client.getUrl(base.replace(path: '${base.path}/models'));
          request.followRedirects = false;
          request.headers
              .set(HttpHeaders.authorizationHeader, 'Bearer ${apiKey.trim()}');
          final response = await request.close();
          if (response.statusCode != 200) {
            await response.drain<void>();
            if ([404, 405].contains(response.statusCode) &&
                base != location.candidates.last) {
              continue;
            }
            throw ChatServiceError(response.statusCode, listing: true);
          }
          try {
            final data = jsonDecode(utf8.decode(await _bytes(response)));
            final catalog = ChatModelCatalog.parse(base, data, apiKey);
            if (generation != _generation) {
              throw const FormatException('连接设置操作已取消。');
            }
            return catalog;
          } on FormatException catch (error) {
            if (base == location.candidates.last ||
                !(error is ChatCatalogFormatError || error.source != null)) {
              rethrow;
            }
          }
        }
        throw const FormatException('未获取到有效模型列表。');
      })()
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw const FormatException('获取模型超时，请检查网络或代理连接。');
    } on SocketException {
      throw const FormatException('无法连接模型服务，请检查地址、网络或代理。');
    } on HttpException {
      throw const FormatException('获取模型时连接中断，请重试。');
    } finally {
      client.close(force: true);
      if (identical(_active, client)) _active = null;
    }
  }

  Future<ChatConnection> resolveConnection(
      String address, String apiKey, String model,
      {String protocol = 'auto', String? preferredProtocol}) async {
    final location = ChatServiceAddress.parse(address);
    ChatConnection.validateKey(apiKey);
    if (model.trim().isEmpty ||
        !['auto', 'chat', 'responses'].contains(protocol)) {
      throw const FormatException('请选择模型，或在高级设置填写模型名。');
    }
    final generation = _generation;
    final prefer = preferredProtocol ??
        location.protocolHint ??
        (['api.openai.com', 'api.deepseek.com'].contains(location.base.host)
            ? 'responses'
            : 'chat');
    final protocols = protocol == 'auto'
        ? [prefer, prefer == 'chat' ? 'responses' : 'chat']
        : [protocol];
    FormatException? failure;
    for (final base in location.candidates) {
      for (final candidate in protocols) {
        if (generation != _generation) {
          throw const FormatException('连接设置操作已取消。');
        }
        final connection = ChatConnection(
            endpoint: ChatServiceAddress.endpoint(base, candidate).toString(),
            model: model.trim(),
            apiKey: apiKey.trim(),
            protocol: candidate);
        try {
          final reply = await complete(connection, [
            {'role': 'user', 'content': 'Reply OK.'}
          ], []);
          if (generation != _generation) {
            throw const FormatException('连接设置操作已取消。');
          }
          if (reply.calls.isNotEmpty || reply.text.isEmpty) {
            throw const FormatException('连接验证未返回有效对话，未保存配置。');
          }
          return connection;
        } on ChatServiceError catch (error) {
          if (!error.protocolMismatch) rethrow;
          failure = error;
        } on FormatException catch (error) {
          // Only a response-format mismatch permits protocol fallback.
          if (!error.message.startsWith('模型返回格式无效')) rethrow;
          failure = error;
        }
      }
    }
    throw failure ?? const FormatException('未找到可用的模型接口。');
  }

  Future<List<int>> _bytes(HttpClientResponse response) async {
    final bytes = <int>[];
    await for (final chunk in response) {
      if (bytes.length + chunk.length > 2 * 1024 * 1024) {
        throw const FormatException('模型响应过大。');
      }
      bytes.addAll(chunk);
    }
    return bytes;
  }

  Future<ChatReply> complete(
      ChatConnection connection,
      List<Map<String, dynamic>> messages,
      List<Map<String, dynamic>> tools) async {
    final uri = connection.uri;
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    _active = client;
    try {
      return await _request(client, uri, connection, messages, tools)
          .timeout(const Duration(seconds: 60));
    } on TimeoutException {
      throw const FormatException('模型请求超时。已执行的软件操作不会自动重试。');
    } on SocketException {
      throw const FormatException('无法连接模型服务，请检查地址与网络。');
    } on HttpException {
      throw const FormatException('模型连接中断，请检查网络。');
    } finally {
      client.close(force: true);
      if (identical(_active, client)) _active = null;
    }
  }

  Future<ChatReply> _request(
      HttpClient client,
      Uri uri,
      ChatConnection c,
      List<Map<String, dynamic>> messages,
      List<Map<String, dynamic>> tools) async {
    final responses = c.protocol == 'responses';
    final body = <String, dynamic>{'model': c.model.trim(), 'stream': false};
    if (responses) {
      body['store'] = false;
      final input = <Map<String, dynamic>>[];
      for (final message in messages) {
        if (message['role'] == 'tool') {
          input.add({
            'type': 'function_call_output',
            'call_id': message['tool_call_id'],
            'output': message['content']
          });
        } else if (message['responseOutput'] is List) {
          input.addAll((message['responseOutput'] as List)
              .map((v) => Map<String, dynamic>.from(v as Map)));
        } else {
          input.add(
              {'role': message['role'], 'content': message['content'] ?? ''});
        }
      }
      body['input'] = input;
      if (tools.isNotEmpty) {
        body['tools'] = tools
            .map((t) => {
                  'type': 'function',
                  ...Map<String, dynamic>.from(t['function'] as Map)
                })
            .toList();
      }
    } else {
      body['messages'] = messages
          .map((m) => Map<String, dynamic>.from(m)..remove('responseOutput'))
          .toList();
      if (tools.isNotEmpty) body['tools'] = tools;
      // DeepSeek requires prior reasoning_content when tools are present.
      // Restored visible history deliberately omits private reasoning.
      if (uri.host == 'api.deepseek.com' &&
          tools.isNotEmpty &&
          messages.any((m) =>
              m['role'] == 'assistant' &&
              !m.containsKey('reasoning_content'))) {
        body['thinking'] = {'type': 'disabled'};
      }
    }
    final request = await client.postUrl(uri);
    request.followRedirects = false;
    request.headers.contentType = ContentType.json;
    request.headers
        .set(HttpHeaders.authorizationHeader, 'Bearer ${c.apiKey.trim()}');
    request.add(utf8.encode(jsonEncode(body)));
    final response = await request.close();
    if (response.statusCode != 200) {
      await response.drain<void>();
      throw ChatServiceError(response.statusCode);
    }
    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
      if (bytes.length > 2 * 1024 * 1024) {
        throw const FormatException('模型响应过大。');
      }
    }
    try {
      final data = jsonDecode(utf8.decode(bytes)) as Map;
      final calls = <ChatToolCall>[];
      String text = '';
      Map<String, dynamic> message;
      if (responses) {
        if (data['status'] != 'completed') {
          throw const FormatException('模型响应未完成，请重试。');
        }
        final output = data['output'] as List;
        for (final item in output.whereType<Map>()) {
          if (item['type'] == 'function_call') {
            calls.add(_call(item['call_id'], item['name'], item['arguments']));
          } else if (item['type'] == 'message') {
            for (final content in (item['content'] as List).whereType<Map>()) {
              if (content['type'] == 'refusal') {
                throw const FormatException('模型拒绝了本次请求。');
              }
              if (content['type'] == 'output_text') {
                text += content['text'] as String;
              }
            }
          }
        }
        message = {
          'role': 'assistant',
          'content': text,
          'responseOutput': output
        };
        if (calls.isNotEmpty) {
          message['tool_calls'] = calls
              .map((v) => {
                    'id': v.id,
                    'type': 'function',
                    'function': {
                      'name': v.name,
                      'arguments': jsonEncode(v.arguments)
                    }
                  })
              .toList();
        }
      } else {
        final choice = (data['choices'] as List).single as Map;
        if (!['stop', 'tool_calls'].contains(choice['finish_reason'])) {
          throw const FormatException('模型响应不完整，未执行新操作。');
        }
        message = Map<String, dynamic>.from(choice['message'] as Map);
        if (message['refusal'] != null) {
          throw const FormatException('模型拒绝了本次请求。');
        }
        text = message['content'] as String? ?? '';
        final reasoning = message['reasoning_content'];
        if (reasoning != null && reasoning is! String) {
          throw const FormatException('模型推理字段格式无效。');
        }
        for (final value
            in (message['tool_calls'] as List? ?? []).whereType<Map>()) {
          if (value['type'] != 'function') {
            throw const FormatException('不支持此工具类型。');
          }
          final function = value['function'] as Map;
          calls
              .add(_call(value['id'], function['name'], function['arguments']));
        }
        message.remove('refusal');
        message = {
          'role': 'assistant',
          'content': text,
          if (reasoning is String) 'reasoning_content': reasoning,
          if (calls.isNotEmpty)
            'tool_calls': calls
                .map((v) => {
                      'id': v.id,
                      'type': 'function',
                      'function': {
                        'name': v.name,
                        'arguments': jsonEncode(v.arguments)
                      }
                    })
                .toList()
        };
      }
      if ((text.isEmpty && calls.isEmpty) ||
          calls.length > 12 ||
          calls.map((v) => v.id).toSet().length != calls.length) {
        throw const FormatException('模型未返回有效回答或工具调用。');
      }
      return ChatReply(text, calls, message);
    } on FormatException catch (error) {
      if (error.source != null) {
        throw const FormatException('模型返回格式无效，请检查所选协议。');
      }
      rethrow;
    } catch (_) {
      throw const FormatException('模型返回格式无效，请检查所选协议。');
    }
  }

  ChatToolCall _call(dynamic id, dynamic name, dynamic arguments) {
    if (id is! String ||
        id.isEmpty ||
        name is! String ||
        arguments is! String) {
      throw const FormatException('工具字段缺失。');
    }
    final args = jsonDecode(arguments);
    if (args is! Map<String, dynamic>) {
      throw const FormatException('工具参数须为JSON对象。');
    }
    return ChatToolCall(id, name, args);
  }
}
