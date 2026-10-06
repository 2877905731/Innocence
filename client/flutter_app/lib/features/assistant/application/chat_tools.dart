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
