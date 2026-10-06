import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/features/assistant/application/chat_controller.dart';
import 'package:innocence_flutter/features/assistant/data/chat_discovery.dart';
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
  String? qaFont;
  setUpAll(() async {
    final file = File(r'C:\Windows\Fonts\msyh.ttc');
    if (await file.exists()) {
      await (FontLoader('ChatQa')
            ..addFont(
                Future.value(ByteData.sublistView(await file.readAsBytes()))))
          .load();
      qaFont = 'ChatQa';
    }
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  for (final theme in [AppVisualTheme.minimalism, AppVisualTheme.glass]) {
    for (final width in [320.0, 820.0, 1280.0]) {
      testWidgets('chat ${theme.name} at $width large text and keyboard',
          (tester) async {
        final identity = ValueNotifier<String>('a');
        final c = AssistantChatController(
            identity: identity,
            owner: () => identity.value,
            host: FixtureToolHost(),
            repository: MemoryChatRepository(),
            provider: FixtureChatProvider(),
            offlineOnly: false);
        await c.configure(fixtureConnection);
        c.entries.addAll([
          const ChatEntry('user', '看看今天的计划，帮我安排明天'),
          const ChatEntry('assistant', '我会先读取现有安排，再根据可用时间提出建议。保存前会请你确认具体任务。')
        ]);
        tester.view.physicalSize = Size(width, 860);
        tester.view.devicePixelRatio = 1;
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        final key = GlobalKey();
        await tester.pumpWidget(MaterialApp(
            theme: AppVisualTokens.of(theme).toThemeData(theme).copyWith(
                textTheme: AppVisualTokens.of(theme)
                    .toThemeData(theme)
                    .textTheme
                    .apply(fontFamily: qaFont)),
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.5)),
                child: child!),
            home: RepaintBoundary(
                key: key,
                child: AssistantChatPage(
                    controller: c,
                    language: AppLanguage.simplifiedChinese,
                    visualTheme: theme))));
        await tester.pumpAndSettle();
        await tester.enterText(
            find.byKey(const ValueKey('chat-input')), '修改建议，保留原任务');
        expect(tester.takeException(), isNull);
        expect(tester.getRect(find.byKey(const ValueKey('chat-input'))).bottom,
            lessThanOrEqualTo(580));
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final img = await boundary.toImage(pixelRatio: 1);
          final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
          final output = Directory('build/qa/chat');
          await output.create(recursive: true);
          await File('${output.path}/${theme.name}-${width.toInt()}.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          img.dispose();
        });
        await tester.pumpWidget(const SizedBox.shrink());
        c.dispose();
        identity.dispose();
      });
    }
  }
  testWidgets(
      'connection dialog saves user settings without exposing existing key',
      (tester) async {
    final identity = ValueNotifier<String>('a'),
        repository = MemoryChatRepository();
    final provider = FixtureChatProvider()
      ..catalog = ChatModelCatalog(Uri.parse('http://127.0.0.1:9999'),
          const [ChatAvailableModel('fixture')])
      ..replies.add(textReply('OK'));
    final c = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: FixtureToolHost(),
        repository: repository,
        provider: provider,
        offlineOnly: false);
    await tester.pumpWidget(MaterialApp(
        home: AssistantChatPage(
            controller: c,
            language: AppLanguage.simplifiedChinese,
            visualTheme: AppVisualTheme.minimalism)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('chat-settings')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('chat-endpoint')),
        fixtureConnection.endpoint);
    await tester.enterText(
        find.byKey(const ValueKey('chat-key')), fixtureConnection.apiKey);
    expect(find.byKey(const ValueKey('chat-model')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('chat-discover-models')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('chat-model-picker')), findsOneWidget);
    expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('chat-key')))
            .obscureText,
        true);
    await tester.tap(find.byKey(const ValueKey('chat-save-connection')));
    await tester.pumpAndSettle();
    expect(c.connection!.model, 'fixture');
    expect(repository.settings['a']!.apiKey, fixtureConnection.apiKey);
    expect(provider.tools.single, isEmpty);
    await tester.tap(find.byKey(const ValueKey('chat-settings')));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('chat-key')))
            .controller!
            .text,
        isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    c.dispose();
    identity.dispose();
  });
  for (final (width, theme) in [
    (320.0, AppVisualTheme.glass),
    (1280.0, AppVisualTheme.minimalism)
  ]) {
    testWidgets('model discovery picker at $width with keyboard and large text',
        (tester) async {
      final identity = ValueNotifier<String>('a');
      final provider = FixtureChatProvider()
        ..catalog =
            ChatModelCatalog(Uri.parse('http://127.0.0.1:9999/v1'), const [
          ChatAvailableModel('model-a', name: '模型A'),
          ChatAvailableModel('model-b', name: '模型B')
        ])
        ..replies.add(textReply('OK'));
      final c = AssistantChatController(
          identity: identity,
          owner: () => identity.value,
          host: FixtureToolHost(),
          repository: MemoryChatRepository(),
          provider: provider,
          offlineOnly: false);
      tester.view.physicalSize = Size(width, 860);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final root = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
          key: root,
          child: MaterialApp(
              theme: AppVisualTokens.of(theme).toThemeData(theme).copyWith(
                  textTheme: AppVisualTokens.of(theme)
                      .toThemeData(theme)
                      .textTheme
                      .apply(fontFamily: qaFont)),
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.5)),
                  child: child!),
              home: AssistantChatPage(
                  controller: c,
                  language: AppLanguage.simplifiedChinese,
                  visualTheme: theme))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('chat-settings')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('chat-endpoint')), 'http://127.0.0.1:9999');
      await tester.enterText(
          find.byKey(const ValueKey('chat-key')), fixtureConnection.apiKey);
      await tester
          .ensureVisible(find.byKey(const ValueKey('chat-discover-models')));
      await tester.tap(find.byKey(const ValueKey('chat-discover-models')));
      await tester.pumpAndSettle();
      await tester
          .ensureVisible(find.byKey(const ValueKey('chat-model-picker')));
      await tester.tap(find.byKey(const ValueKey('chat-model-picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('模型B · model-b').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final boundary =
            root.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final img = await boundary.toImage(pixelRatio: 1);
        final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
        final output = Directory('build/qa/discovery');
        await output.create(recursive: true);
        await File('${output.path}/${theme.name}-${width.toInt()}.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        img.dispose();
      });
      await tester.tap(find.byKey(const ValueKey('chat-save-connection')));
      await tester.pumpAndSettle();
      expect(c.connection!.model, 'model-b');
      expect(
          c.connection!.endpoint, 'http://127.0.0.1:9999/v1/chat/completions');
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
      identity.dispose();
    });
  }
  testWidgets(
      'editing address invalidates the list and never reuses a key across origins',
      (tester) async {
    final identity = ValueNotifier<String>('a');
    final c = AssistantChatController(
        identity: identity,
        owner: () => identity.value,
        host: FixtureToolHost(),
        repository: MemoryChatRepository(),
        provider: FixtureChatProvider(),
        offlineOnly: false);
    await c.configure(fixtureConnection);
    await tester.pumpWidget(MaterialApp(
        home: AssistantChatPage(
            controller: c,
            language: AppLanguage.simplifiedChinese,
            visualTheme: AppVisualTheme.minimalism)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('chat-settings')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('chat-endpoint')),
        'https://different.example');
    await tester.tap(find.byKey(const ValueKey('chat-discover-models')));
    await tester.pumpAndSettle();
    expect(c.error, '请填写有效API Key。');
    expect(find.byKey(const ValueKey('chat-model-picker')), findsNothing);
    expect(c.connection, same(fixtureConnection));
    await tester.pumpWidget(const SizedBox.shrink());
    c.dispose();
    identity.dispose();
  });
}
