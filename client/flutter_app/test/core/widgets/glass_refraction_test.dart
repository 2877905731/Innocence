import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/core/widgets/glass_motion_backdrop.dart';
import 'package:innocence_flutter/core/widgets/glass_refractive_surface.dart';

void main() {
  testWidgets(
      'refraction changes sampled beam geometry and follows scene origin',
      (tester) async {
    await tester.runAsync(() async {
      final program =
          await ui.FragmentProgram.fromAsset('shaders/glass_refraction.frag');
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      for (var x = 0; x < 256; x++) {
        canvas.drawRect(Rect.fromLTWH(x.toDouble(), 0, 1, 160),
            Paint()..color = Color.fromARGB(255, x, 0, 255 - x));
      }
      for (var y = 0; y < 160; y++) {
        canvas.drawRect(
            Rect.fromLTWH(0, y.toDouble(), 256, 1),
            Paint()
              ..color = Color.fromARGB(255, 0, y, 0)
              ..blendMode = BlendMode.plus);
      }
      final picture = recorder.endRecording();
      final texture = picture.toImageSync(256, 160);
      picture.dispose();
      Future<Uint8List> render(double strength, double origin,
          {double originY = 20}) async {
        final shader = program.fragmentShader();
        final uniforms = [
          120.0,
          100.0,
          256.0,
          160.0,
          origin,
          originY,
          15.0,
          strength
        ];
        for (var i = 0; i < uniforms.length; i++) {
          shader.setFloat(i, uniforms[i]);
        }
        shader.setImageSampler(0, texture);
        final output = ui.PictureRecorder();
        Canvas(output).drawRect(
            const Rect.fromLTWH(0, 0, 120, 100), Paint()..shader = shader);
        final resultPicture = output.endRecording();
        final image = await resultPicture.toImage(120, 100);
        final bytes = (await image.toByteData())!.buffer.asUint8List();
        image.dispose();
        resultPicture.dispose();
        shader.dispose();
        return bytes;
      }

      final plain = await render(0, 40);
      final refracted = await render(1, 40);
      final moved = await render(0, 70);
      final movedDown = await render(0, 40, originY: 40);
      int red(Uint8List bytes, int x, int y) => bytes[(y * 120 + x) * 4];
      int green(Uint8List bytes, int x, int y) => bytes[(y * 120 + x) * 4 + 1];
      // Zero strength samples the actual scene, including its global origin.
      expect(red(plain, 60, 50), closeTo(100, 2));
      expect(red(moved, 60, 50) - red(plain, 60, 50), closeTo(30, 2));
      expect(green(plain, 60, 50), closeTo(70, 2));
      expect(green(movedDown, 60, 50) - green(plain, 60, 50), closeTo(20, 2));
      var changed = 0;
      for (var i = 0; i < plain.length; i += 4) {
        if ((plain[i] - refracted[i]).abs() > 3) changed++;
        expect(refracted[i + 3], 255);
      }
      expect(changed, greaterThan(120 * 100 * .5));
      // Refraction is spatially varying; it cannot be a single hue/brightness filter.
      expect(red(refracted, 4, 50) - red(plain, 4, 50),
          isNot(red(refracted, 60, 50) - red(plain, 60, 50)));
      texture.dispose();
    });
  });

  testWidgets('surface without a light scene keeps readable interactive frost',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: GlassRefractiveSurface(
      child: TextButton(
          onPressed: () => tapped = true, child: const Text('Action')),
    ))));
    expect(find.byType(BackdropFilter), findsOneWidget);
    await tester.tap(find.text('Action'));
    expect(tapped, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reduced motion holds the shared scene and resizing replaces it',
      (tester) async {
    GlassLightScene? scene;
    Widget view(double width) => MaterialApp(
            home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Center(
              child: SizedBox(
            width: width,
            height: 300,
            child: GlassMotionBackdrop(child: Builder(builder: (context) {
              scene = GlassLightSceneScope.maybeOf(context);
              return const SizedBox.expand();
            })),
          )),
        ));
    await tester.pumpWidget(view(400));
    await tester.pump();
    final first = scene!.image;
    expect(first, isNotNull);
    await tester.pump(const Duration(seconds: 1));
    expect(identical(scene!.image, first), isTrue);
    await tester.pumpWidget(view(500));
    await tester.pump();
    expect(scene!.size, const Size(500, 300));
    expect(identical(scene!.image, first), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
