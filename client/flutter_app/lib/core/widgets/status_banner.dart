import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.message,
    this.onClose,
  });

  final String message;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final visualTheme =
        Theme.of(context).extension<AppVisualThemeMarker>()?.visualTheme;
    final themed = visualTheme == AppVisualTheme.glass ||
        visualTheme == AppVisualTheme.minimalism;
    final tokens = themed ? AppVisualTokens.of(visualTheme!) : null;
    final foreground = tokens?.ink ?? SurfacePalette.dangerInk;
    final iconColor =
        visualTheme == AppVisualTheme.minimalism ? tokens!.accent : foreground;
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foreground,
                ),
          ),
        ),
        if (onClose != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: foreground),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );

    if (themed) {
      return GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: content,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: SurfacePalette.dangerSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SurfacePalette.dangerBorder),
      ),
      child: content,
    );
  }
}
