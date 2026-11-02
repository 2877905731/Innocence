import '../../../core/utils/request_id.dart';

class ChatEntry {
  const ChatEntry(this.role, this.text);
  final String role, text;
  Map<String, dynamic> toJson() => {'role': role, 'text': text};
  factory ChatEntry.fromJson(Map<String, dynamic> value) {
    if (!['user', 'assistant', 'action', 'notice'].contains(value['role']) ||
        value['text'] is! String) {
      throw const FormatException('对话记录格式无效，原记录未覆盖。');
    }
    return ChatEntry(value['role'] as String, value['text'] as String);
  }
}

class ChatConversation {
  const ChatConversation(
      {required this.id,
      this.title = '',
      this.messages = const [],
      this.draft = '',
      this.agentMode = true,
      required this.updatedAt});
  final String id, title, draft;
  final bool agentMode;
  final int updatedAt;
  final List<ChatEntry> messages;
  factory ChatConversation.empty() => ChatConversation(
      id: newRequestId(), updatedAt: DateTime.now().millisecondsSinceEpoch);
  static String titleFrom(String text) => String.fromCharCodes(
      text.replaceAll(RegExp(r'\s+'), ' ').trim().runes.take(48));
  ChatConversation copyWith(
          {String? title,
          List<ChatEntry>? messages,
          String? draft,
          bool? agentMode,
          int? updatedAt}) =>
      ChatConversation(
          id: id,
          title: title ?? this.title,
          messages: messages ?? this.messages,
          draft: draft ?? this.draft,
          agentMode: agentMode ?? this.agentMode,
          updatedAt: updatedAt ?? this.updatedAt);
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': (messages.length > 120
                ? messages.sublist(messages.length - 120)
                : messages)
            .map((m) => m.toJson())
            .toList(),
        'draft': draft,
        'agentMode': agentMode,
        'updatedAt': updatedAt
      };
  factory ChatConversation.fromJson(Map<String, dynamic> value) {
    if (value['id'] is! String ||
        (value['id'] as String).isEmpty ||
        value['title'] is! String ||
        value['draft'] is! String ||
        value['agentMode'] is! bool ||
        value['updatedAt'] is! int ||
        (value['updatedAt'] as int) < 0 ||
        value['messages'] is! List) {
      throw const FormatException('对话格式无效，原记录未覆盖。');
    }
    return ChatConversation(
        id: value['id'] as String,
        title: value['title'] as String,
        draft: value['draft'] as String,
        agentMode: value['agentMode'] as bool,
        updatedAt: value['updatedAt'] as int,
        messages: (value['messages'] as List)
            .map((m) => ChatEntry.fromJson(Map<String, dynamic>.from(m as Map)))
            .toList());
  }
}

class ChatWorkspace {
  const ChatWorkspace({required this.activeId, required this.conversations});
  final String activeId;
  final List<ChatConversation> conversations;
  factory ChatWorkspace.fromLegacy(List<Map<String, dynamic>> history) {
    final messages = history.map(ChatEntry.fromJson).toList();
    final first = messages.where((m) => m.role == 'user').firstOrNull;
    final chat = ChatConversation.empty().copyWith(
        messages: messages,
        title: first == null ? '' : ChatConversation.titleFrom(first.text));
    return ChatWorkspace(activeId: chat.id, conversations: [chat]);
  }
  Map<String, dynamic> toJson() => {
        'version': 2,
        'activeId': activeId,
        'conversations': conversations.map((c) => c.toJson()).toList()
      };
  factory ChatWorkspace.fromJson(Map<String, dynamic> value) {
    if (value['version'] != 2 ||
        value['activeId'] is! String ||
        value['conversations'] is! List) {
      throw const FormatException('对话集合格式无效，原记录未覆盖。');
    }
    final chats = (value['conversations'] as List)
        .map((c) =>
            ChatConversation.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList();
    if (chats.isEmpty ||
        chats.map((c) => c.id).toSet().length != chats.length ||
        !chats.any((c) => c.id == value['activeId'])) {
      throw const FormatException('当前对话标识无效，原记录未覆盖。');
    }
    return ChatWorkspace(
        activeId: value['activeId'] as String, conversations: chats);
  }
}
