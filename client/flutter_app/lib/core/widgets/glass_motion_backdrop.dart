import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'glass_refractive_surface.dart';

/// Render the preview's lights once, sharing the resulting texture with panels.
class GlassMotionBackdrop extends StatefulWidget {
  const GlassMotionBackdrop({super.key, required this.child});
  final Widget child;
  @override
  State<GlassMotionBackdrop> createState() => _GlassMotionBackdropState();
}

class _GlassMotionBackdropState extends State<GlassMotionBackdrop>
    with WidgetsBindingObserver {
  final _scene = GlassLightScene();
  final _clock = Stopwatch();
  Timer? _timer;
  Size _size = Size.zero;
  bool _foreground = true;
  bool _reduceMotion = false;
  bool _layoutPending = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _syncMotion();
    if (_reduceMotion) _renderScene();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncMotion();
  }

  void _syncMotion() {
    if (!_foreground ||
        _reduceMotion ||
        !TickerMode.valuesOf(context).enabled) {
      _timer?.cancel();
      _timer = null;
      _clock.stop();
      return;
    }
    if (_timer != null) return;
    _clock.start();
    _timer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (mounted) _renderScene();
    });
  }

  void _renderScene() {
    if (_size.isEmpty) return;
    // Light already has 22–40 logical px of diffusion. Bound the shared texture
    // rather than allocating a full-resolution copy for every panel and DPI.
    final scale = math.min(1.0, 1440 / math.max(_size.width, _size.height));
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(scale);
    _paintLights(canvas, _size, _reduceMotion ? 0 : _clock.elapsedMilliseconds);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(math.max(1, (_size.width * scale).ceil()),
        math.max(1, (_size.height * scale).ceil()));
    picture.dispose();
    _scene.replace(image, _size);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _scene.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final size = constraints.biggest;
        if (!size.isFinite || size.isEmpty) {
          return ColoredBox(
              color: const Color(0xFF03042C), child: widget.child);
        }
        if (_size != size) {
          _size = size;
          if (!_layoutPending) {
            _layoutPending = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _layoutPending = false;
              if (mounted) _renderScene();
            });
          }
        }
        return GlassLightSceneScope(
            scene: _scene,
            child: ClipRect(
              key: _scene.canvasKey,
              child: ColoredBox(
                  color: const Color(0xFF03042C),
                  child: Stack(fit: StackFit.expand, children: [
                    RepaintBoundary(
                        child: CustomPaint(painter: _ScenePainter(_scene))),
                    widget.child,
                  ])),
            ));
      });
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene) : super(repaint: scene);
  final GlassLightScene scene;
  @override
  void paint(Canvas canvas, Size size) {
    final image = scene.image;
    if (image == null) return;
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Offset.zero & size,
        Paint()..filterQuality = FilterQuality.low);
  }

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) => scene != oldDelegate.scene;
}

double _ease(int elapsed, int duration) {
  final t = (elapsed % duration) / duration;
  return Curves.easeInOut.transform((elapsed ~/ duration).isEven ? t : 1 - t);
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

void _paintLights(Canvas canvas, Size size, int elapsed) {
  final w = size.width;
  final h = size.height;
  final desktop = AppConfig.deviceType == 'windows';
  canvas.drawColor(const Color(0xFF03042C), BlendMode.src);
  canvas.save();
  canvas.translate(w * .8, h * .18);
  canvas.scale(w / h, 1);
  final base = Rect.fromCircle(center: Offset.zero, radius: h * 1.7);
  canvas.drawCircle(
      Offset.zero,
      h * 1.7,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF0A1051), Color(0x000A1051)],
          stops: [0, .58],
        ).createShader(base));
  canvas.restore();
  final broad = _ease(elapsed, 28000);
  final ray = _ease(elapsed, 24000);
  final horizon = _ease(elapsed, 32000);
  void light(
      {required Offset center,
      required Size dimensions,
      required double angle,
      required double scale,
      required double sigma,
      required Gradient gradient}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle * math.pi / 180);
    canvas.scale(scale);
    final rect = Rect.fromCenter(
        center: Offset.zero,
        width: dimensions.width,
        height: dimensions.height);
    final paint = Paint()
      ..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
    if (desktop) {
      paint.colorFilter = const ColorFilter.matrix([
        1.197,
        -.179,
        -.018,
        0,
        0,
        -.053,
        1.071,
        -.018,
        0,
        0,
        -.053,
        -.179,
        1.232,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]);
    }
    canvas.saveLayer(rect.inflate(sigma * 4), paint);
    if (gradient is RadialGradient) {
      canvas.save();
      canvas.scale(dimensions.width / dimensions.height, 1);
      final circle =
          Rect.fromCircle(center: Offset.zero, radius: dimensions.height / 2);
      canvas.drawOval(circle, Paint()..shader = gradient.createShader(circle));
      canvas.restore();
    } else {
      canvas.drawOval(rect, Paint()..shader = gradient.createShader(rect));
    }
    canvas.restore();
    canvas.restore();
  }

  final broadSize = Size(w * (desktop ? 1.25 : 1),
      math.max(h * (desktop ? .32 : .24), desktop ? 208 : 160));
  light(
      center: Offset(
          w * (desktop ? -.375 : -.25) +
              broadSize.width / 2 +
              w * _lerp(-.08, .28, broad),
          h * (desktop ? .42 : .46) +
              broadSize.height / 2 +
              h * _lerp(.10, -.20, broad)),
      dimensions: broadSize,
      angle: _lerp(-28, -16, broad),
      scale: _lerp(.9, 1.15, broad),
      sigma: 40,
      gradient: const LinearGradient(colors: [
        Colors.transparent,
        Color(0xCCB629F5),
        Color(0xFF935AF0),
        Color(0xFF6A4DFB),
        Color(0xED2D2CFF),
        Colors.transparent
      ], stops: [
        0,
        .18,
        .40,
        .57,
        .78,
        1
      ]));
  final raySize = Size(w * (desktop ? 1.12 : .92),
      math.max(h * (desktop ? .095 : .07), desktop ? 54 : 40));
  light(
      center: Offset(
          w * (desktop ? .07 : .17) +
              raySize.width / 2 +
              w * _lerp(-.20, .07, ray),
          h * (desktop ? .535 : .55) +
              raySize.height / 2 +
              h * _lerp(.23, -.17, ray)),
      dimensions: raySize,
      angle: _lerp(-31, -19, ray),
      scale: 1,
      sigma: 22,
      gradient: const LinearGradient(colors: [
        Colors.transparent,
        Color(0xFFF897FE),
        Color(0xFFC78DFF),
        Color(0xFF935AF0),
        Color(0xFF483ACC),
        Color(0x992D2CFF),
        Colors.transparent
      ], stops: [
        0,
        .22,
        .37,
        .54,
        .72,
        .84,
        1
      ]));
  final blueSize = Size(
      math.max(w * (desktop ? .68 : .55), desktop ? 500 : 420),
      h * (desktop ? .50 : .40));
  light(
      center: Offset(
          w * (desktop ? .565 : .63) +
              blueSize.width / 2 +
              w * _lerp(.10, -.40, horizon),
          h * (desktop ? .20 : .25) +
              blueSize.height / 2 +
              h * _lerp(-.08, .35, horizon)),
      dimensions: blueSize,
      angle: 0,
      scale: _lerp(.9, 1.2, horizon),
      sigma: 36,
      gradient: const RadialGradient(
          colors: [Color(0xDC2D2CFF), Color(0xB3172090), Color(0x00172090)],
          stops: [0, .38, .72]));
}
