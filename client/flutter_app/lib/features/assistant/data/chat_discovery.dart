import 'chat_repository.dart';

class ChatServiceAddress {
  ChatServiceAddress._(this.base, this.protocolHint);
  final Uri base;
  final String? protocolHint;
  factory ChatServiceAddress.parse(String address) {
    final uri = ChatConnection.validateAddress(address);
    var path = uri.path.replaceFirst(RegExp(r'/+$'), '');
    String? hint;
    for (final suffix in ['/chat/completions', '/responses', '/models']) {
      if (path.endsWith(suffix)) {
        path = path.substring(0, path.length - suffix.length);
        hint = suffix == '/responses'
            ? 'responses'
            : suffix == '/chat/completions'
                ? 'chat'
                : null;
        break;
      }
    }
    return ChatServiceAddress._(uri.replace(path: path), hint);
  }

  List<Uri> get candidates {
    if (RegExp(r'/v\d+$').hasMatch(base.path)) return [base];
    final versioned = base.replace(path: '${base.path}/v1');
    return base.host == 'api.openai.com' && base.path.isEmpty
        ? [versioned, base]
        : [base, versioned];
  }

  static Uri endpoint(Uri base, String protocol) => base.replace(
      path:
          '${base.path}/${protocol == 'responses' ? 'responses' : 'chat/completions'}');
}

class ChatAvailableModel {
  const ChatAvailableModel(this.id, {this.name, this.preferredProtocol});
  final String id;
  final String? name, preferredProtocol;
  String get label => name == null || name == id ? id : '$name · $id';
}

class ChatModelCatalog {
  const ChatModelCatalog(this.base, this.models);
  final Uri base;
  final List<ChatAvailableModel> models;
  factory ChatModelCatalog.parse(Uri base, dynamic data, String key) {
    if (data is! Map || data['data'] is! List) {
      throw const ChatCatalogFormatError();
    }
    final models = <ChatAvailableModel>[];
    final seen = <String>{};
    for (final value in data['data'] as List) {
      if (value is! Map || value['id'] is! String) {
        throw const FormatException('模型列表缺少有效模型标识。');
      }
      final id = value['id'] as String;
      if (id.trim().isEmpty ||
          id != id.trim() ||
          id.length > 256 ||
          id.contains(RegExp(r'[\r\n]')) ||
          id.contains(key)) {
        throw const FormatException('模型列表包含无效模型标识。');
      }
      if (!seen.add(id)) continue;
      final name = value['name'];
      models.add(ChatAvailableModel(id,
          name: name is String &&
                  name.isNotEmpty &&
                  name.length <= 256 &&
                  !name.contains(key) &&
                  !name.contains(RegExp(r'[\r\n]'))
              ? name
              : null));
      if (models.length > 1000) {
        throw const FormatException('服务返回的模型数量过多。');
      }
    }
    if (models.isEmpty) {
      throw const FormatException('此密钥没有返回可用模型；请核对服务权限或在高级设置手动填写。');
    }
    return ChatModelCatalog(base, models);
  }
}

class ChatCatalogFormatError extends FormatException {
  const ChatCatalogFormatError() : super('服务返回的模型列表格式不兼容；可在高级设置手动填写模型。');
}

class ChatServiceError extends FormatException {
  ChatServiceError(this.status, {bool listing = false})
      : super(switch (status) {
          401 => 'API Key无效或已过期，请重新填写。',
          403 => '此API Key没有访问权限，请检查服务权限。',
          402 => '模型服务余额不足，请在服务商控制台查看。',
          429 => '模型服务额度或频率受限，请稍后再试。',
          404 || 405 when listing => '此地址不提供模型列表；请核对服务地址或在高级设置手动填写模型。',
          _ when listing => '获取模型失败（HTTP $status），请检查服务地址。',
          _ => '模型服务请求失败（HTTP $status），请检查所选模型与服务支持的协议。'
        });
  final int status;
  bool get protocolMismatch => [400, 404, 405, 415, 422, 501].contains(status);
}
