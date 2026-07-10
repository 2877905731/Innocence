import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';
import 'package:innocence_flutter/core/widgets/aurora_background.dart';
import 'package:innocence_flutter/core/widgets/desktop_close_button.dart';
import 'package:innocence_flutter/core/widgets/material_localization_scope.dart';

class SecondaryPageScaffold extends StatelessWidget {
  const SecondaryPageScaffold({
    super.key,
    required this.backLabel,
    required this.title,
    required this.description,
    required this.children,
    this.headerActions = const <Widget>[],
    this.padding = const EdgeInsets.all(20),
  });

  final String backLabel;
  final String title;
  final String description;
  final List<Widget> headerActions;
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final trailingActions = <Widget>[
      ...headerActions,
      if (AppConfig.deviceType == 'windows')
        const DesktopCloseButton(compact: true),
    ];

    return MaterialLocalizationScope(
      child: Theme(
        data: SurfacePalette.homeTheme(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: AuroraBackground(
            lightStyle: true,
            child: SafeArea(
              child: ListView(
                padding: padding,
                children: [
                  Wrap(
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
                                Text(
                                  title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
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
                  ),
                  if (children.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    ...children,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
