import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/config/runtime_capabilities.dart';
import 'package:innocence_flutter/core/layout/desktop_presentation.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';
import 'package:innocence_flutter/core/widgets/adaptive_canvas_shell.dart';
import 'package:innocence_flutter/core/widgets/desktop_close_button.dart';

import '../../features/home/desktop_daily_slogan_test.dart'
    show desktopSloganFixture;

void main() {
  String? qaFont;
  setUpAll(() async {
    if (!const bool.fromEnvironment('HARMONY_QA_CAPTURE')) return;
    final font = File(r'C:\Windows\Fonts\msyh.ttc');
    if (await font.exists()) {
      final bytes = ByteData.sublistView(await font.readAsBytes());
      // Host captures use a CJK QA fallback, not device font evidence.
      for (final family in [
        'HarmonyQa',
        'Segoe UI',
        'Segoe UI Variable Display',
        'Century Gothic',
        'Georgia'
      ]) {
        await (FontLoader(family)..addFont(Future.value(bytes))).load();
      }
      qaFont = 'HarmonyQa';
    }
    final icons = File(
        r'D:\soft\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf');
    if (await icons.exists()) {
      await (FontLoader('MaterialIcons')
            ..addFont(
                Future.value(ByteData.sublistView(await icons.readAsBytes()))))
          .load();
    }
  });
  test('Harmony device identity stays separate from PC presentation', () {
    const tablet = RuntimeCapabilities(operatingSystem: 'ohos');
    expect(tablet.deviceType, 'harmonyos');
    expect(tablet.usesPcLayout, isTrue);
    expect(tablet.supportsDesktopWindow, isFalse);
    expect(tablet.restoresLocalWorkspace, isTrue);
    const unknown = RuntimeCapabilities(operatingSystem: 'unknown');
    expect(unknown.deviceType, isNot('windows'));
    expect(unknown.supportsDesktopWindow, isFalse);
  });

  final tabletRun = AppConfig.capabilities.isHarmonyTablet;
  test('first Harmony build cannot call the account API', () {
    expect(AppConfig.offlineOnlyBuild, isTrue);
    expect(AppConfig.apiBaseUrl, isEmpty);
  }, skip: !tabletRun);
  testWidgets('tablet retains PC rail when a keyboard consumes height',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final size in [
      const Size(1360, 900),
      const Size(1360, 390),
      const Size(1024, 768),
      const Size(1024, 360),
    ]) {
      tester.view.physicalSize = size;
      DesktopPresentationSpec? observed;
      await tester.pumpWidget(MaterialApp(
        home: DesktopPresentationLayout(
          surface: DesktopWindowSurface.canvas,
          builder: (_, spec) {
            observed = spec;
            return const SizedBox.expand();
          },
        ),
      ));
      await tester.pump();
      expect(
          observed!.tier,
          size.width >= 1180
              ? DesktopPresentationTier.large
              : DesktopPresentationTier.medium);
      expect(observed!.navigation, isNot(NavigationPresentation.bottomBar));
      expect(tester.takeException(), isNull);
    }
  }, skip: !tabletRun);

  testWidgets('tablet window controls and native bridge stay inactive',
      (tester) async {
    final nativeCalls = <MethodCall>[];
    const channel = MethodChannel('innocence/desktop_widget');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) async {
      nativeCalls.add(call);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(const MaterialApp(
        home: Column(children: [
      DesktopWindowControls(),
      DesktopCanvasSizeButton(),
      DesktopMinimizeButton(),
      DesktopCloseButton(),
    ])));
    expect(find.byTooltip('大画布'), findsNothing);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
    expect(find.byIcon(Icons.remove_rounded), findsNothing);
    await DesktopWidgetBridge.showOrbWindow();
    await DesktopWidgetBridge.showCanvasWindow();
    await DesktopWidgetBridge.closeWindow();
    expect(nativeCalls, isEmpty);
  }, skip: !tabletRun);

  testWidgets('tablet PC home preserves four themes and hides Orb',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final size in [const Size(1360, 900), const Size(1024, 768)]) {
      tester.view.physicalSize = size;
      for (final theme in AppVisualTheme.values) {
        final imageKey = GlobalKey();
        await tester.pumpWidget(RepaintBoundary(
          key: imageKey,
          child: desktopSloganFixture(theme, AppLanguage.simplifiedChinese,
              fontFamily: qaFont),
        ));
        await tester.pump(const Duration(milliseconds: 50));
        final shell = tester
            .widget<AdaptiveCanvasShell>(find.byType(AdaptiveCanvasShell));
        expect(shell.onOpenFocusOrb, isNull);
        expect(find.byTooltip('大画布'), findsNothing);
        expect(find.text('Synthetic focus'), findsWidgets);
        expect(tester.takeException(), isNull);
        if (const bool.fromEnvironment('HARMONY_QA_CAPTURE')) {
          await tester.runAsync(() async {
            final boundary = imageKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 1);
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            final directory = Directory('build/qa/harmony-tablet');
            await directory.create(recursive: true);
            await File(
                    '${directory.path}/${theme.name}-${size.width.toInt()}.png')
                .writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  }, skip: !tabletRun);
}
