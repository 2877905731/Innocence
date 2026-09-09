import 'dart:async';

import 'package:flutter/material.dart';

import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';

enum DesktopResizeEdge {
  left,
  right,
  top,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class DesktopResizeFrame extends StatelessWidget {
  const DesktopResizeFrame({
    super.key,
    required this.child,
    this.enabled = true,
    this.edgeThickness = 10,
    this.cornerSize = 20,
  });

  final Widget child;
  final bool enabled;
  final double edgeThickness;
  final double cornerSize;

  @override
  Widget build(BuildContext context) {
    if (!enabled || AppConfig.deviceType != 'windows') {
      return child;
    }

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: 0,
          left: cornerSize,
          right: cornerSize,
          height: edgeThickness,
          child: const _ResizeHandle(edge: DesktopResizeEdge.top),
        ),
        Positioned(
          bottom: 0,
          left: cornerSize,
          right: cornerSize,
          height: edgeThickness,
          child: const _ResizeHandle(edge: DesktopResizeEdge.bottom),
        ),
        Positioned(
          top: cornerSize,
          bottom: cornerSize,
          left: 0,
          width: edgeThickness,
          child: const _ResizeHandle(edge: DesktopResizeEdge.left),
        ),
        Positioned(
          top: cornerSize,
          bottom: cornerSize,
          right: 0,
          width: edgeThickness,
          child: const _ResizeHandle(edge: DesktopResizeEdge.right),
        ),
        Positioned(
          top: 0,
          left: 0,
          width: cornerSize,
          height: cornerSize,
          child: const _ResizeHandle(edge: DesktopResizeEdge.topLeft),
        ),
        Positioned(
          top: 0,
          right: 0,
          width: cornerSize,
          height: cornerSize,
          child: const _ResizeHandle(edge: DesktopResizeEdge.topRight),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          width: cornerSize,
          height: cornerSize,
          child: const _ResizeHandle(edge: DesktopResizeEdge.bottomLeft),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          width: cornerSize,
          height: cornerSize,
          child: const _ResizeHandle(edge: DesktopResizeEdge.bottomRight),
        ),
      ],
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({required this.edge});

  final DesktopResizeEdge edge;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: ValueKey('desktop-resize-${edge.name}'),
      cursor: switch (edge) {
        DesktopResizeEdge.left ||
        DesktopResizeEdge.right =>
          SystemMouseCursors.resizeLeftRight,
        DesktopResizeEdge.top ||
        DesktopResizeEdge.bottom =>
          SystemMouseCursors.resizeUpDown,
        DesktopResizeEdge.topLeft ||
        DesktopResizeEdge.bottomRight =>
          SystemMouseCursors.resizeUpLeftDownRight,
        DesktopResizeEdge.topRight ||
        DesktopResizeEdge.bottomLeft =>
          SystemMouseCursors.resizeUpRightDownLeft,
      },
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          unawaited(DesktopWidgetBridge.startWindowResize(edge.name));
        },
        child: const SizedBox.expand(),
      ),
    );
  }
}
