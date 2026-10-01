import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// One background texture per canvas, shared by all its glass surfaces. It
/// contains only the decorative lights, never text or account content.
class GlassLightScene extends ChangeNotifier {
  final canvasKey = GlobalKey();
  ui.Image? image;
  Size size = Size.zero;

  void replace(ui.Image next, Size nextSize) {
    final previous = image;
    image = next;
    size = nextSize;
    notifyListeners();
    // The previous texture can still be referenced by this frame's display list.
    if (previous != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
    }
  }

  @override
  void dispose() {
    final previous = image;
    image = null;
    if (previous != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
    }
    super.dispose();
  }
}

class GlassLightSceneScope extends InheritedWidget {
  const GlassLightSceneScope({
    super.key,
    required this.scene,
    required super.child,
  });

  final GlassLightScene scene;

  static GlassLightScene? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlassLightSceneScope>()?.scene;

  @override
  bool updateShouldNotify(GlassLightSceneScope oldWidget) =>
      scene != oldWidget.scene;
}

/// Refracts the same background texture displayed by GlassMotionBackdrop.
/// Canvas shaders support Windows/Skia as well as Android/Impeller; an
/// ImageFilter.shader would exclude the Windows backend.
class GlassRefractiveSurface extends StatefulWidget {
  const GlassRefractiveSurface({
    super.key,
    required this.child,
    this.radius = 15,
    this.strength = 1,
  });

  final Widget child;
  final double radius;
  final double strength;

  @override
  State<GlassRefractiveSurface> createState() => _GlassRefractiveSurfaceState();
}

class _GlassRefractiveSurfaceState extends State<GlassRefractiveSurface> {
  static Future<ui.FragmentProgram>? _program;
  final _paintKey = GlobalKey();
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await (_program ??= ui.FragmentProgram.fromAsset(
        'shaders/glass_refraction.frag',
      ));
      if (mounted) setState(() => _shader = program.fragmentShader());
    } catch (error) {
      _program = null;
      // Keep readable frosted content if an asset/backend cannot load the shader.
      debugPrint('Glass refraction shader unavailable: ${error.runtimeType}');
    }
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = GlassLightSceneScope.maybeOf(context);
    final shader = _shader;
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      // Keep the child's element tree stable while the shader loads: changing
      // wrappers here would reset forms, focus and in-flight progress animations.
      child: BackdropFilter(
        enabled: scene == null || shader == null,
        filter: ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: CustomPaint(
          key: _paintKey,
          painter: scene == null || shader == null
              ? null
              : _RefractionPainter(
                  scene: scene,
                  shader: shader,
                  paintKey: _paintKey,
                  radius: widget.radius,
                  strength: widget.strength,
                ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _RefractionPainter extends CustomPainter {
  _RefractionPainter({
    required this.scene,
    required this.shader,
    required this.paintKey,
    required this.radius,
    required this.strength,
  }) : super(repaint: scene);

  final GlassLightScene scene;
  final ui.FragmentShader shader;
  final GlobalKey paintKey;
  final double radius;
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    final image = scene.image;
    final sourceBox = scene.canvasKey.currentContext?.findRenderObject();
    final panelBox = paintKey.currentContext?.findRenderObject();
    if (image == null ||
        sourceBox is! RenderBox ||
        panelBox is! RenderBox ||
        size.isEmpty ||
        scene.size.isEmpty) {
      return;
    }
    // Resolve at paint time, so scrolling, resizing and hover transforms keep
    // the beam anchored to the canvas instead of restarting inside each card.
    final origin = panelBox.localToGlobal(Offset.zero, ancestor: sourceBox);
    final uniforms = [
      size.width,
      size.height,
      scene.size.width,
      scene.size.height,
      origin.dx,
      origin.dy,
      radius,
      strength
    ];
    for (var index = 0; index < uniforms.length; index++) {
      shader.setFloat(index, uniforms[index]);
    }
    shader.setImageSampler(0, image);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_RefractionPainter oldDelegate) =>
      scene != oldDelegate.scene ||
      shader != oldDelegate.shader ||
      radius != oldDelegate.radius ||
      strength != oldDelegate.strength;
}
