import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';

class DesktopWindowControls extends StatelessWidget {
  const DesktopWindowControls({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DesktopMinimizeButton(compact: compact),
        const SizedBox(width: 6),
        DesktopCloseButton(compact: compact),
      ],
    );
  }
}

class DesktopMinimizeButton extends StatelessWidget {
  const DesktopMinimizeButton({super.key, this.tooltip, this.compact = false});

  final String? tooltip;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _DesktopControlButton(
      tooltip: tooltip ?? '最小化',
      compact: compact,
      icon: Icons.remove_rounded,
      onTap: DesktopWidgetBridge.minimizeWindow,
    );
  }
}

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
    return _DesktopControlButton(
      tooltip: tooltip ?? '退出',
      compact: compact,
      icon: Icons.close_rounded,
      onTap: DesktopWidgetBridge.closeWindow,
    );
  }
}

class _DesktopControlButton extends StatelessWidget {
  const _DesktopControlButton({
    required this.tooltip,
    required this.compact,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final bool compact;
  final IconData icon;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final buttonSize = compact ? 34.0 : 40.0;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: colors.outline.withValues(alpha: 0.8)),
          ),
          child: Icon(icon, size: compact ? 17 : 19, color: colors.onSurface),
        ),
      ),
    );
  }
}
