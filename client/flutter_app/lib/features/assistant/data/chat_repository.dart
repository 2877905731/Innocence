import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/chat_conversation.dart';

class ChatConnection {
  const ChatConnection(
      {this.endpoint = '',
      this.model = '',
      this.apiKey = '',
      this.protocol = 'chat'});
  final String endpoint, model, apiKey, protocol;
  static Uri validateAddress(String address) {
    final value = Uri.tryParse(address.trim());
    if (value == null ||
        value.host.isEmpty ||
        value.userInfo.isNotEmpty ||
        value.hasFragment ||
        value.hasQuery ||
        !(value.scheme == 'https' ||
            (value.scheme == 'http' &&
                ['127.0.0.1', 'localhost', '::1'].contains(value.host)))) {
      throw const FormatException('服务地址须为HTTPS；本机模型可使用localhost HTTP。');
    }
    return value;
  }

  static void validateKey(String key) {
    if (key.trim().isEmpty || key.contains(RegExp(r'[\r\n]'))) {
      throw const FormatException('请填写有效API Key。');
    }
  }

  Uri get uri {
    final value = validateAddress(endpoint);
    validateKey(apiKey);
    if (!['chat', 'responses'].contains(protocol) ||
        model.trim().isEmpty ||
        apiKey.trim().isEmpty ||
        apiKey.contains(RegExp(r'[\r\n]'))) {
      throw const FormatException('请填写模型名、API Key和支持的协议。');
    }
    return value;
  }

  Map<String, dynamic> toJson() => {
        'endpoint': endpoint,
        'model': model,
        'apiKey': apiKey,
        'protocol': protocol
      };
  factory ChatConnection.fromJson(Map<String, dynamic> j) => ChatConnection(
      endpoint: j['endpoint'] as String,
      model: j['model'] as String,
      apiKey: j['apiKey'] as String,
      protocol: j['protocol'] as String);
}

abstract class ChatRepository {
  Future<ChatConnection?> loadConnection(String owner);
  Future<void> saveConnection(String owner, ChatConnection connection);
  Future<void> deleteConnection(String owner);
  Future<List<Map<String, dynamic>>> loadHistory(String owner);
  Future<void> saveHistory(String owner, List<Map<String, dynamic>> messages);
  Future<ChatWorkspace> loadWorkspace(String owner);
  Future<void> saveWorkspace(String owner, ChatWorkspace workspace);
  Future<void> deleteWorkspace(String owner);
}

class NativeChatRepository implements ChatRepository {
  static const _channel = MethodChannel('innocence/assistant_vault');
  String _key(String owner, String kind) =>
      'assistant.$kind.${base64Url.encode(utf8.encode(owner))}';

  @override
  Future<ChatWorkspace> loadWorkspace(String owner) async {
    if (owner.isEmpty) throw ArgumentError('Owner is required');
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(owner, 'conversations'));
    final workspace = raw == null
        ? ChatWorkspace.fromLegacy(await loadHistory(owner))
        : ChatWorkspace.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw) as Map));
    if (raw == null) await saveWorkspace(owner, workspace);
    // Never remove the legacy history until the complete migrated workspace is durable.
    if (prefs.containsKey(_key(owner, 'history')) &&
        !await prefs.remove(_key(owner, 'history'))) {
      throw const FormatException('历史迁移尚未完成，请重试；记录已保留。');
    }
    return workspace;
  }

  @override
  Future<void> saveWorkspace(String owner, ChatWorkspace workspace) async {
    if (owner.isEmpty) throw ArgumentError('Owner is required');
    final data = workspace.toJson();
    ChatWorkspace.fromJson(data);
    if (!await (await SharedPreferences.getInstance())
        .setString(_key(owner, 'conversations'), jsonEncode(data))) {
      throw const FormatException('对话保存失败，请重试。');
    }
  }

  @override
  Future<void> deleteWorkspace(String owner) async {
    if (owner.isEmpty) throw ArgumentError('Owner is required');
    final prefs = await SharedPreferences.getInstance();
    for (final kind in ['conversations', 'history']) {
      final key = _key(owner, kind);
      if (prefs.containsKey(key) && !await prefs.remove(key)) {
        throw const FormatException('删除本机对话失败，请重试。');
      }
    }
  }

  @override
  Future<ChatConnection?> loadConnection(String owner) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key(owner, 'connection'));
    if (value == null) return null;
    final bytes =
        await _channel.invokeMethod<Uint8List>('decrypt', base64Decode(value));
    if (bytes == null) throw const FormatException('本机密钥无法解密，请重新配置。');
    return ChatConnection.fromJson(
        Map<String, dynamic>.from(jsonDecode(utf8.decode(bytes)) as Map));
  }

  @override
  Future<void> saveConnection(String owner, ChatConnection connection) async {
    connection.uri;
    final bytes = await _channel.invokeMethod<Uint8List>('encrypt',
        Uint8List.fromList(utf8.encode(jsonEncode(connection.toJson()))));
    if (bytes == null) throw const FormatException('本机加密存储不可用；未保存密钥。');
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(
        _key(owner, 'connection'), base64Encode(bytes))) {
      throw const FormatException('保存连接失败。');
    }
  }

  @override
  Future<void> deleteConnection(String owner) async =>
      (await SharedPreferences.getInstance()).remove(_key(owner, 'connection'));
  @override
  Future<List<Map<String, dynamic>>> loadHistory(String owner) async {
    final value = (await SharedPreferences.getInstance())
        .getString(_key(owner, 'history'));
    if (value == null) return [];
    return (jsonDecode(value) as List)
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList();
  }

  @override
  Future<void> saveHistory(
      String owner, List<Map<String, dynamic>> messages) async {
    final value = messages.length > 120
        ? messages.sublist(messages.length - 120)
        : messages;
    await (await SharedPreferences.getInstance())
        .setString(_key(owner, 'history'), jsonEncode(value));
  }
}
