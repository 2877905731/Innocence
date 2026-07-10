import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';

class DesktopDragRegion extends StatelessWidget {
  const DesktopDragRegion({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (AppConfig.deviceType != 'windows') {
      return child ?? const SizedBox.shrink();
    }

    return MouseRegion(
      cursor: SystemMouseCursors.move,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) {
          DesktopWidgetBridge.startWindowDrag();
        },
        child: child ?? const SizedBox.expand(),
      ),
    );
  }
}
