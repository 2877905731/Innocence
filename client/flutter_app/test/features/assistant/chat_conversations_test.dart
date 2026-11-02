import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:innocence_flutter/features/assistant/application/chat_controller.dart';
import 'package:innocence_flutter/features/assistant/data/chat_repository.dart';
import 'package:innocence_flutter/features/assistant/domain/chat_conversation.dart';
import 'chat_assistant_test.dart'
    show
        MemoryChatRepository,
        FixtureChatProvider,
        FixtureToolHost,
        fixtureConnection,
        textReply,
        toolReply,
        eventually;

class FailingWorkspaceRepository extends MemoryChatRepository {
  bool fail = false;
  @override
  Future<void> saveWorkspace(String owner, ChatWorkspace workspace) async {
    if (fail) throw const FormatException('synthetic write failure');
    await super.saveWorkspace(owner, workspace);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'new chats preserve messages drafts modes and use only their own model context',
      () async {
    final identity = ValueNotifier('a'), repo = MemoryChatRepository();
    final provider = FixtureChatProvider()
      ..replies.addAll([
        textReply('first answer'),
        textReply('second answer'),
        textReply('first follow-up')
      ]);
    final c = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: FixtureToolHost(),
        repository: repo,
        provider: provider,
        offlineOnly: false);
    try {
      await c.configure(fixtureConnection);
      await c.initialize();
      c.setAgentMode(false);
      await c.send('first question');
      final first = c.activeConversationId!;
      c.draft = 'first draft';
      expect(await c.createConversation(), isTrue);
      final second = c.activeConversationId!;
      expect(second, isNot(first));
      expect(c.entries, isEmpty);
      expect(c.draft, isEmpty);
      c.setAgentMode(false);
      await c.send('second question');
      expect(
          provider.requests.last
              .any((m) => '${m['content']}'.contains('first question')),
          isFalse);
      c.draft = 'second draft';
      expect(await c.selectConversation(first), isTrue);
      expect(c.draft, 'first draft');
      expect(c.agentMode, isFalse);
      expect(c.entries.first.text, 'first question');
      await c.send('continue the first');
      expect(provider.requests.last.any((m) => m['content'] == 'first answer'),
          isTrue);
      expect(
          provider.requests.last.any((m) => m['content'] == 'second question'),
          isFalse);
      expect(await c.selectConversation(second), isTrue);
      expect(c.draft, 'second draft');
      expect(await c.deleteConversation(first), isTrue);
      expect(c.activeConversationId, second);
      expect(c.conversations, hasLength(1));
      expect(await c.deleteConversation(second), isTrue);
      expect(c.conversations, hasLength(1));
      expect(c.entries, isEmpty);
      expect(repo.settings['a'], same(fixtureConnection));
    } finally {
      c.dispose();
      identity.dispose();
    }
  });

  test(
      'switching identities saves the old draft and restores independent conversation sets',
      () async {
    final identity = ValueNotifier('a'), repo = MemoryChatRepository();
    final c = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: FixtureToolHost(),
        repository: repo,
        provider: FixtureChatProvider(),
        offlineOnly: false);
    try {
      await c.initialize();
      final first = c.activeConversationId;
      c.draft = 'owner-a draft';
      identity.value = 'b';
      await c.initialize();
      expect(c.draft, isEmpty);
      expect(c.activeConversationId, isNot(first));
      c.draft = 'owner-b draft';
      identity.value = 'a';
      await c.initialize();
      expect(c.activeConversationId, first);
      expect(c.draft, 'owner-a draft');
      expect(repo.workspaces['b']!.conversations.single.draft, 'owner-b draft');
    } finally {
      c.dispose();
      identity.dispose();
    }
  });

  test(
      'pending writes cannot move to another chat and restore never replays a confirmation',
      () async {
    final identity = ValueNotifier('a'),
        repo = MemoryChatRepository(),
        host = FixtureToolHost();
    final provider = FixtureChatProvider()
      ..replies.addAll([toolReply(), textReply('cancelled')]);
    final c = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: host,
        repository: repo,
        provider: provider,
        offlineOnly: false);
    try {
      await c.configure(fixtureConnection);
      final sending = c.send('prepare one write');
      await eventually(() => c.pending != null);
      final original = c.activeConversationId;
      expect(await c.createConversation(), isFalse);
      expect(await c.deleteConversation(original!), isFalse);
      c.stop();
      await sending;
      expect(host.writes, 0);
      expect(await c.createConversation(), isTrue);
      expect(await c.selectConversation(original), isTrue);
      expect(c.pending, isNull);
      expect(host.writes, 0);
    } finally {
      c.dispose();
      identity.dispose();
    }
  });

  test(
      'failed persistence keeps the old selection and prevents a false deletion',
      () async {
    final identity = ValueNotifier('a'), repo = FailingWorkspaceRepository();
    final c = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: FixtureToolHost(),
        repository: repo,
        offlineOnly: false);
    try {
      await c.initialize();
      c.draft = 'keep me';
      await c.createConversation();
      final current = c.activeConversationId!, count = c.conversations.length;
      repo.fail = true;
      expect(await c.deleteConversation(current), isFalse);
      expect(c.activeConversationId, current);
      expect(c.conversations.length, count);
      expect(c.error, contains('已保留'));
      repo.fail = false;
    } finally {
      c.dispose();
      identity.dispose();
    }
  });

  test(
      'legacy migration preserves exact text, deletes old keys only after saving and keeps owners isolated',
      () async {
    String key(String owner, String kind) =>
        'assistant.$kind.${base64Url.encode(utf8.encode(owner))}';
    const text = '原文\n保留空格  与 emoji 🌱';
    SharedPreferences.setMockInitialValues({
      key('a', 'history'): jsonEncode([
        {'role': 'user', 'text': text},
        {'role': 'action', 'text': '执行结果待核对'}
      ])
    });
    final repo = NativeChatRepository(),
        prefs = await SharedPreferences.getInstance();
    final a = await repo.loadWorkspace('a');
    expect(
        a.conversations.single.messages.first.text.codeUnits, text.codeUnits);
    expect(prefs.containsKey(key('a', 'history')), isFalse);
    expect(
        jsonDecode(prefs.getString(key('a', 'conversations'))!)['version'], 2);
    final b = await repo.loadWorkspace('b');
    expect(b.conversations.single.messages, isEmpty);
    await repo.deleteWorkspace('a');
    expect(prefs.containsKey(key('a', 'conversations')), isFalse);
    expect(prefs.containsKey(key('b', 'conversations')), isTrue);
    expect(
        (await repo.loadWorkspace('a')).conversations.single.messages, isEmpty);
  });

  test(
      'corrupt new history is reported without erasing it or falling back to legacy content',
      () async {
    final key = 'assistant.conversations.${base64Url.encode(utf8.encode('a'))}';
    SharedPreferences.setMockInitialValues({key: '{invalid'});
    final repo = NativeChatRepository(),
        prefs = await SharedPreferences.getInstance();
    await expectLater(repo.loadWorkspace('a'), throwsFormatException);
    expect(prefs.getString(key), '{invalid');
  });

  test('drafts and inactive conversations never persist the current model key',
      () async {
    final identity = ValueNotifier('a'), repo = MemoryChatRepository();
    final c = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: FixtureToolHost(),
        repository: repo,
        offlineOnly: false);
    try {
      await c.configure(fixtureConnection);
      await c.initialize();
      c.draft = 'secret ${fixtureConnection.apiKey}';
      await c.createConversation();
      c.draft = fixtureConnection.apiKey;
      await c.flushDraft();
      expect(jsonEncode(repo.workspaces['a']!.toJson()),
          isNot(contains(fixtureConnection.apiKey)));
    } finally {
      c.dispose();
      identity.dispose();
    }
  });
}
