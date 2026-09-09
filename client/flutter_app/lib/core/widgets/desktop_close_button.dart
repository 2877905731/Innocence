import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';

class DesktopWindowControls extends StatelessWidget {
  const DesktopWindowControls({
    super.key,
    this.compact = false,
    this.showSizePresets = true,
    this.showMinimize = true,
  });

  final bool compact;
  final bool showSizePresets;
  final bool showMinimize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showSizePresets) ...[
          DesktopCanvasSizeButton(compact: compact),
          const SizedBox(width: 7),
        ],
        if (showMinimize) ...[
          DesktopMinimizeButton(compact: compact),
          const SizedBox(width: 7),
        ],
        DesktopCloseButton(compact: compact),
      ],
    );
  }
}

class DesktopCanvasSizeButton extends StatelessWidget {
  const DesktopCanvasSizeButton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: '界面大小',
      container: true,
      child: Container(
        height: compact ? 34 : 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.72),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CanvasSizePresetButton(
              preset: 'large',
              tooltip: '大画布',
              glyphDiameter: compact ? 20 : 23,
              compact: compact,
            ),
            _CanvasSizeDivider(colors: colors),
            _CanvasSizePresetButton(
              preset: 'medium',
              tooltip: '中画布',
              glyphDiameter: compact ? 15 : 17,
              compact: compact,
            ),
            _CanvasSizeDivider(colors: colors),
            _CanvasSizePresetButton(
              preset: 'small',
              tooltip: '小画布',
              glyphDiameter: compact ? 10 : 11,
              compact: compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _CanvasSizePresetButton extends StatefulWidget {
  const _CanvasSizePresetButton({
    required this.preset,
    required this.tooltip,
    required this.glyphDiameter,
    required this.compact,
  });

  final String preset;
  final String tooltip;
  final double glyphDiameter;
  final bool compact;

  @override
  State<_CanvasSizePresetButton> createState() =>
      _CanvasSizePresetButtonState();
}

class _CanvasSizePresetButtonState extends State<_CanvasSizePresetButton> {
  bool _hovered = false;

  Future<void> _selectPreset() async {
    await DesktopWidgetBridge.setCanvasSizePreset(widget.preset);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final width = widget.compact ? 30.0 : 36.0;
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          key: ValueKey('canvas-size-${widget.preset}'),
          onTap: _selectPreset,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: width,
            height: widget.compact ? 28 : 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _hovered
                  ? colors.primary.withValues(alpha: 0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              key: ValueKey('canvas-size-glyph-${widget.preset}'),
              width: widget.glyphDiameter,
              height: widget.glyphDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: _hovered ? 0.18 : 0.08),
                border: Border.all(
                  color: _hovered ? colors.primary : colors.onSurfaceVariant,
                  width: 2,
                ),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.28),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Container(
                  width: widget.glyphDiameter * 0.28,
                  height: widget.glyphDiameter * 0.28,
                  decoration: BoxDecoration(
                    color: colors.onSurface,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CanvasSizeDivider extends StatelessWidget {
  const _CanvasSizeDivider({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 18,
      color: colors.outlineVariant.withValues(alpha: 0.48),
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
      destructive: true,
    );
  }
}

class _DesktopControlButton extends StatefulWidget {
  const _DesktopControlButton({
    required this.tooltip,
    required this.compact,
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });

  final String tooltip;
  final bool compact;
  final IconData icon;
  final Future<void> Function() onTap;
  final bool destructive;

  @override
  State<_DesktopControlButton> createState() => _DesktopControlButtonState();
}

class _DesktopControlButtonState extends State<_DesktopControlButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final buttonSize = widget.compact ? 34.0 : 40.0;
    final hoverColor = widget.destructive
        ? colors.error.withValues(alpha: 0.22)
        : colors.primary.withValues(alpha: 0.16);
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(11),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: buttonSize,
            height: buttonSize,
            alignment: Alignment.center,
            decoration: _controlDecoration(
              context,
              color: _hovered ? hoverColor : null,
              highlighted: _hovered,
            ),
            child: Icon(
              widget.icon,
              size: widget.compact ? 17 : 19,
              color: widget.destructive && _hovered
                  ? colors.error
                  : colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _controlDecoration(
  BuildContext context, {
  Color? color,
  bool highlighted = false,
}) {
  final colors = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: color ?? colors.surface.withValues(alpha: 0.34),
    borderRadius: BorderRadius.circular(11),
    border: Border.all(
      color: highlighted
          ? colors.primary.withValues(alpha: 0.62)
          : colors.outlineVariant.withValues(alpha: 0.72),
    ),
    boxShadow: [
      BoxShadow(
        color: colors.shadow.withValues(alpha: highlighted ? 0.16 : 0.08),
        blurRadius: highlighted ? 14 : 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
