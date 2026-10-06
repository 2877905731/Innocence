import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';

/// Neutral canvas separates white workspaces using tone and precise borders.
class MinimalWhiteBackdrop extends StatelessWidget {
  const MinimalWhiteBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
      color: AppVisualTokens.of(AppVisualTheme.minimalism).canvas,
      child: child);
}
