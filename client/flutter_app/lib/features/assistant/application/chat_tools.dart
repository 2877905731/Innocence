import '../data/chat_provider.dart';

class PreparedChatTool {
  const PreparedChatTool(
      {required this.summary, required this.execute, this.confirm = false});
  final String summary;
  final bool confirm;
  final Future<Map<String, dynamic>> Function() execute;
}

abstract class ChatToolHost {
  void cancel() {}
  List<Map<String, dynamic>> get definitions;
  Future<PreparedChatTool> prepare(ChatToolCall call);
}

class ChatToolFailure extends FormatException {
  const ChatToolFailure(this.errorCode, String message,
      {required this.requestId,
      this.clientEntityId,
      this.statusCode,
      String source = 'client'})
      : failureSource = source,
        super(message);
  final Object errorCode;
  final String requestId, failureSource;
  final String? clientEntityId;
  final int? statusCode;
  Map<String, dynamic> toJson() => {
        'ok': false,
        'reason': 'OPERATION_FAILED',
        'errorCode': errorCode,
        'message': message,
        'requestId': requestId,
        'source': failureSource,
        if (clientEntityId != null) 'clientEntityId': clientEntityId,
        if (statusCode != null) 'statusCode': statusCode
      };
}

Map<String, dynamic> chatTool(
        String name, String description, Map<String, dynamic> properties,
        {List<String>? required}) =>
    {
      'type': 'function',
      'function': {
        'name': name,
        'description': description,
        'strict': false,
        'parameters': {
          'type': 'object',
          'properties': properties,
          'required': required ?? properties.keys.toList(),
          'additionalProperties': false
        }
      }
    };
const chatString = {'type': 'string'};
const chatInteger = {'type': 'integer'};
