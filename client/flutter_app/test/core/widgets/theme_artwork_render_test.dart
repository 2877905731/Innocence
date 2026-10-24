import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/app/wabi_sabi_typography.dart';
import 'package:innocence_flutter/core/widgets/glass_motion_backdrop.dart';
import 'package:innocence_flutter/core/widgets/glass_refractive_surface.dart';
import 'package:innocence_flutter/features/auth/presentation/widgets/auth_experience.dart';

import '../../features/home/android_home_shell_test.dart' as android;
import '../../features/home/desktop_daily_slogan_test.dart' as desktop;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in {
      'CrimsonText': [
        'assets/fonts/crimson_text/CrimsonText-Regular.ttf',
        'assets/fonts/crimson_text/CrimsonText-Italic.ttf',
      ],
      'NotoSerifSC': ['assets/fonts/noto_serif_sc/NotoSerifSC-Variable.ttf'],
      'MaterialIcons': ['fonts/MaterialIcons-Regular.otf'],
    }.entries) {
      final loader = FontLoader(entry.key);
      for (final asset in entry.value) {
        loader.addFont(rootBundle.load(asset));
      }
      await loader.load();
    }
    // Host body text uses a local CJK sans face; device rendering is verified
    // separately. Display faces above always come from the application bundle.
    final sans = File(r'C:\Windows\Fonts\msyh.ttc');
    if (await sans.exists()) {
      await (FontLoader('Segoe UI')
            ..addFont(
                Future.value(ByteData.sublistView(await sans.readAsBytes()))))
          .load();
    }
  });

  Future<ui.Image> capture(WidgetTester tester, String name) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('artwork-capture')));
    late ui.Image image;
    await tester.runAsync(() async {
      image = await boundary.toImage(pixelRatio: 2);
      const output = String.fromEnvironment('ARTWORK_OUTPUT');
      if (output.isNotEmpty) {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('$output/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
      }
    });
    return image;
  }

  testWidgets('display assets render distinct Latin italic and Chinese glyphs',
      (tester) async {
    await tester.runAsync(() async {
      Future<List<int>> glyphs(String value, {bool italic = false}) async {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.drawColor(Colors.white, BlendMode.src);
        final painter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: value,
            style: WabiSabiTypography.heading(const TextStyle(
                    fontSize: 48,
                    color: Colors.black,
                    fontWeight: FontWeight.w400))
                .copyWith(
                    fontStyle: italic ? FontStyle.italic : FontStyle.normal),
          ),
        )..layout(maxWidth: 600);
        painter.paint(canvas, const Offset(8, 8));
        painter.dispose();
        final picture = recorder.endRecording();
        final image = await picture.toImage(600, 90);
        final bytes = (await image.toByteData())!.buffer.asUint8List().toList();
        image.dispose();
        picture.dispose();
        return bytes;
      }

      // Missing-glyph boxes would be identical for these two Chinese characters.
      expect(await glyphs('静'), isNot(await glyphs('念')));
      expect(await glyphs('Innocence', italic: true),
          isNot(await glyphs('Innocence')));
    });
  });

  testWidgets('bundled artwork fits Android and PC with real display glyphs',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final size in [const Size(411, 890), const Size(1400, 920)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(RepaintBoundary(
        key: const ValueKey('artwork-capture'),
        child: size.width < 600
            ? android.androidHomeFixture(visualTheme: AppVisualTheme.wabiSabi)
            : desktop.desktopSloganFixture(
                AppVisualTheme.wabiSabi, AppLanguage.simplifiedChinese),
      ));
      await tester.pump(const Duration(milliseconds: 350));
      final image = await capture(tester, 'wabi-${size.width.toInt()}');
      expect(image.width, size.width * 2);
      image.dispose();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(RepaintBoundary(
        key: const ValueKey('artwork-capture'),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppVisualTokens.of(AppVisualTheme.wabiSabi)
              .toThemeData(AppVisualTheme.wabiSabi),
          home: AuthExperience(
            language: AppLanguage.simplifiedChinese,
            visualTheme: AppVisualTheme.wabiSabi,
            onThemeChanged: (_) {},
            stageNumber: '01',
            title: '留一点空白',
            description: '从一个清晰的步骤开始。',
            child: const Text('Innocence'),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 350));
      final brand = await capture(tester, 'wabi-brand-${size.width.toInt()}');
      brand.dispose();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('glass light field and refraction render at tablet density',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data:
            const MediaQueryData(disableAnimations: true, devicePixelRatio: 2),
        child: RepaintBoundary(
          key: const ValueKey('artwork-capture'),
          child: GlassMotionBackdrop(
            child: Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 450,
                height: 330,
                child: GlassRefractiveSurface(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white24),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.runAsync(() async =>
        ui.FragmentProgram.fromAsset('shaders/glass_refraction.frag'));
    await tester.pump();
    final image = await capture(tester, 'glass-2800');
    expect(image.width, 2800);
    image.dispose();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
