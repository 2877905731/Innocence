import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/features/assistant/application/chat_controller.dart';
import 'package:innocence_flutter/features/assistant/presentation/assistant_chat_page.dart';
import 'chat_assistant_test.dart'
    show
        MemoryChatRepository,
        FixtureChatProvider,
        FixtureToolHost,
        fixtureConnection,
        textReply;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('ConversationQa')
          ..addFont(Future.value(ByteData.sublistView(
              await File(r'C:\Windows\Fonts\msyh.ttc').readAsBytes()))))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  for (final theme in AppVisualTheme.values) {
    for (final width in [320.0, 1280.0]) {
      testWidgets(
          'multi conversation ${theme.name} $width preserves drafts and confirms deletion',
          (tester) async {
        final identity = ValueNotifier('a'), repo = MemoryChatRepository();
        final provider = FixtureChatProvider()
          ..replies.addAll([textReply('第一条回复'), textReply('第二条回复')]);
        final c = AssistantChatController(
            identity: identity,
            owner: () => identity.value,
            host: FixtureToolHost(),
            repository: repo,
            provider: provider,
            offlineOnly: false);
        await c.initialize();
        await c.configure(fixtureConnection);
        c.setAgentMode(false);
        await c.send('学习规划');
        final first = c.activeConversationId!;
        c.draft = '保留第一份草稿';
        await c.createConversation();
        c.setAgentMode(false);
        await c.send('读书笔记');
        c.draft = '第二份草稿';
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        tester.view.viewInsets = const FakeViewPadding(bottom: 240);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        final root = GlobalKey();
        await tester.pumpWidget(MaterialApp(
            theme: AppVisualTokens.of(theme).toThemeData(theme).copyWith(
                textTheme: AppVisualTokens.of(theme)
                    .toThemeData(theme)
                    .textTheme
                    .apply(fontFamily: 'ConversationQa')),
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.5)),
                child: child!),
            home: RepaintBoundary(
                key: root,
                child: AssistantChatPage(
                    controller: c,
                    language: AppLanguage.simplifiedChinese,
                    visualTheme: theme))));
        await tester.pumpAndSettle();
        Future<void> openList() async {
          if (width < 900) {
            await tester.tap(find.byKey(const ValueKey('chat-conversations')));
            await tester.pumpAndSettle();
          }
        }

        await openList();
        await tester.tap(find.byKey(ValueKey('chat-conversation-$first')));
        await tester.pumpAndSettle();
        expect(c.activeConversationId, first);
        expect(
            tester
                .widget<TextField>(find.byKey(const ValueKey('chat-input')))
                .controller!
                .text,
            '保留第一份草稿');
        await openList();
        await tester.tap(find.byKey(
            ValueKey(width < 900 ? 'chat-drawer-new' : 'chat-sidebar-new')));
        await tester.pumpAndSettle();
        final fresh = c.activeConversationId!;
        expect(c.conversations, hasLength(3));
        await openList();
        await tester.tap(find.byKey(ValueKey('chat-delete-$fresh')));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, '取消'));
        await tester.pumpAndSettle();
        expect(c.conversations, hasLength(3));
        await tester.tap(find.byKey(ValueKey('chat-delete-$fresh')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('chat-confirm-delete')));
        await tester.pumpAndSettle();
        expect(c.conversations, hasLength(2));
        expect(c.conversations.any((chat) => chat.id == first), isTrue);
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image = await (root.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final folder = Directory('build/qa/chat-conversations');
          await folder.create(recursive: true);
          await File('${folder.path}/${theme.name}-${width.toInt()}.png')
              .writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox.shrink());
        c.dispose();
        identity.dispose();
      });
    }
  }
}
