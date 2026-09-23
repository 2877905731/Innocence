import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/widgets/desktop_close_button.dart';
import 'package:innocence_flutter/core/widgets/glass_motion_backdrop.dart';
import 'package:innocence_flutter/core/widgets/material_localization_scope.dart';
import 'package:innocence_flutter/core/widgets/soft_spectrum_backdrop.dart';
import 'package:innocence_flutter/core/widgets/wabi_sabi_paper.dart';

class SecondaryPageScaffold extends StatelessWidget {
  const SecondaryPageScaffold({
    super.key,
    required this.backLabel,
    required this.title,
    required this.description,
    required this.children,
    this.visualTheme,
    this.headerActions = const <Widget>[],
    this.padding = const EdgeInsets.all(20),
    this.pinHeader = false,
  });

  final String backLabel;
  final String title;
  final String description;
  final AppVisualTheme? visualTheme;
  final List<Widget> headerActions;
  final List<Widget> children;
  final EdgeInsets padding;
  final bool pinHeader;

  @override
  Widget build(BuildContext context) {
    final resolvedVisualTheme = visualTheme ??
        Theme.of(context).extension<AppVisualThemeMarker>()?.visualTheme ??
        AppVisualTheme.minimalism;
    final trailingActions = <Widget>[
      ...headerActions,
      if (AppConfig.deviceType == 'windows')
        const DesktopWindowControls(compact: true),
    ];
    final tokens = AppVisualTokens.of(resolvedVisualTheme);
    final header = _SecondaryPageHeader(
      backLabel: backLabel,
      title: title,
      description: description,
      trailingActions: trailingActions,
    );
    final content = SafeArea(
      child: pinHeader
          ? Column(
              children: [
                Padding(padding: padding, child: header),
                Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant),
                Expanded(
                  child: ListView(
                    padding: padding,
                    children: children,
                  ),
                ),
              ],
            )
          : ListView(
              padding: padding,
              children: [
                header,
                if (children.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  ...children,
                ],
              ],
            ),
    );

    return MaterialLocalizationScope(
      child: Scaffold(
        backgroundColor: tokens.canvas,
        body: switch (resolvedVisualTheme) {
          AppVisualTheme.minimalism => SoftSpectrumBackdrop(child: content),
          AppVisualTheme.wabiSabi =>
            WabiSabiPaper(color: tokens.canvas, child: content),
          AppVisualTheme.glass => GlassMotionBackdrop(child: content),
          AppVisualTheme.midCentury =>
            ColoredBox(color: tokens.canvas, child: content),
        },
      ),
    );
  }
}

class _SecondaryPageHeader extends StatelessWidget {
  const _SecondaryPageHeader({
    required this.backLabel,
    required this.title,
    required this.description,
    required this.trailingActions,
  });

  final String backLabel;
  final String title;
  final String description;
  final List<Widget> trailingActions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(backLabel),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (trailingActions.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: trailingActions,
          ),
      ],
    );
  }
}
