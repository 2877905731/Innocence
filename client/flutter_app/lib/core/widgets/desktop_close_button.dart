import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';

class DesktopCloseButton extends StatelessWidget {
  const DesktopCloseButton({
    super.key,
    this.tooltip,
    this.compact = false,
  });

  final String? tooltip;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double iconSize = compact ? 18 : 20;
    final double buttonSize = compact ? 38 : 42;

    return Tooltip(
      message: tooltip ?? '\u9000\u51fa',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            await DesktopWidgetBridge.closeWindow();
          },
          child: Container(
            width: buttonSize,
            height: buttonSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: SurfacePalette.border,
                width: 1,
              ),
              boxShadow: SurfacePalette.shadows,
            ),
            child: Icon(
              Icons.close_rounded,
              size: iconSize,
              color: SurfacePalette.ink,
            ),
          ),
        ),
      ),
    );
  }
}
