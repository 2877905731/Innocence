import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';

/// Retains Material's modal routing, focus and result handling while frosting
/// the page behind glass dialogs. Business text is never used as a light scene.
Future<T?> showThemedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  TraversalEdgeBehavior? traversalEdgeBehavior,
  bool? requestFocus,
  AnimationStyle? animationStyle,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    traversalEdgeBehavior: traversalEdgeBehavior,
    requestFocus: requestFocus,
    animationStyle: animationStyle,
    builder: (context) {
      final theme = Theme.of(context);
      final glass = theme.extension<AppVisualThemeMarker>()?.visualTheme ==
          AppVisualTheme.glass;
      if (!glass) return builder(context);

      final highContrast = MediaQuery.highContrastOf(context);
      final dialogTheme = theme.copyWith(
        canvasColor: const Color(0xF21D202A),
        colorScheme: theme.colorScheme.copyWith(
          surface: const Color(0xF21D202A),
          surfaceContainer: const Color(0xF21D202A),
        ),
        dialogTheme: theme.dialogTheme.copyWith(
          backgroundColor: highContrast
              ? const Color(0xFA181A24)
              : theme.dialogTheme.backgroundColor,
        ),
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          fillColor: const Color(0x26FFFFFF),
          labelStyle: const TextStyle(color: Color(0xFFE5E7EF)),
          floatingLabelStyle: const TextStyle(color: Color(0xFFF5F6FA)),
          hintStyle: const TextStyle(color: Color(0xBFD9DDE8)),
        ),
      );
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Theme(
            data: dialogTheme,
            child: Builder(builder: builder),
          ),
        ),
      );
    },
  );
}
