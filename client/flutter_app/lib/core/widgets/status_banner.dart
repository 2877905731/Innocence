import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: SurfacePalette.dangerInk,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SurfacePalette.dangerInk,
                  ),
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onClose,
              icon: const Icon(
                Icons.close_rounded,
                color: SurfacePalette.dangerInk,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}
