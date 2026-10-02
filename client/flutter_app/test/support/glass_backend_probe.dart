// Run with flutter run -t test/support/glass_backend_probe.dart on an isolated
// Android emulator. This uses the real engine; host widget tests only use Skia.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/widgets/glass_motion_backdrop.dart';
import 'package:innocence_flutter/core/widgets/glass_refractive_surface.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _ProbeApp());
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final program =
        await ui.FragmentProgram.fromAsset('shaders/glass_refraction.frag');
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (var y = 0; y < 160; y++) {
      canvas.drawRect(Rect.fromLTWH(0, y.toDouble(), 256, 1),
          Paint()..color = Color.fromARGB(255, 40, y, 64));
    }
    final picture = recorder.endRecording();
    final texture = picture.toImageSync(256, 160);
    picture.dispose();
    final shader = program.fragmentShader();
    final uniforms = [120.0, 100.0, 256.0, 160.0, 40.0, 20.0, 15.0, 0.0];
    for (var i = 0; i < uniforms.length; i++) {
      shader.setFloat(i, uniforms[i]);
    }
    shader.setImageSampler(0, texture);
    final output = ui.PictureRecorder();
    Canvas(output).drawRect(
        const Rect.fromLTWH(0, 0, 120, 100), Paint()..shader = shader);
    final renderedPicture = output.endRecording();
    final image = await renderedPicture.toImage(120, 100);
    final bytes = (await image.toByteData())!.buffer.asUint8List();
    final samples =
        [10, 50, 80].map((y) => bytes[(y * 120 + 60) * 4 + 1]).toList();
    final passed =
        List.generate(3, (i) => (samples[i] - [30, 70, 100][i]).abs() <= 2)
            .every((value) => value);
    debugPrint(
        'GLASS_BACKEND_PROBE ${passed ? "PASS" : "FAIL"}: green=$samples expected=[30, 70, 100]');
    image.dispose();
    renderedPicture.dispose();
    shader.dispose();
    texture.dispose();
  });
}

class _ProbeApp extends StatelessWidget {
  const _ProbeApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: GlassMotionBackdrop(
            child: SafeArea(
                child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Glass backend probe',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
                const SizedBox(height: 120),
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassRefractiveSurface(
                      radius: 18,
                      child: Container(
                        height: 150,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0x35FFFFFF))),
                        child: Text('Panel ${i + 1}',
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
              ],
            )),
          ),
        ),
      );
}
