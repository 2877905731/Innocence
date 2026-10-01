import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_language.dart';

class AndroidLanguageSelectionPage extends StatelessWidget {
  const AndroidLanguageSelectionPage({
    super.key,
    required this.controller,
  });

  final AppLanguageController controller;

  @override
  Widget build(BuildContext context) {
    final language = controller.currentLanguage;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Innocence')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                Icon(
                  Icons.translate_rounded,
                  size: 40,
                  color: colors.primary,
                ),
                const SizedBox(height: 24),
                Text(language.startupTitle,
                    style: theme.textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text(language.startupDescription,
                    style: theme.textTheme.bodyLarge),
                const SizedBox(height: 28),
                for (final option in AppLanguage.values) ...[
                  Card(
                    clipBehavior: Clip.antiAlias,
                    color: option == language
                        ? colors.secondaryContainer
                        : colors.surfaceContainerLow,
                    child: ListTile(
                      selected: option == language,
                      onTap: () => controller.previewLanguage(option),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      title: Text(option.label),
                      subtitle: Text(
                        option == AppLanguage.simplifiedChinese
                            ? 'Simplified Chinese'
                            : '英语 / English',
                      ),
                      trailing: option == language
                          ? Icon(Icons.check_circle_rounded,
                              color: colors.primary)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: FilledButton(
            onPressed: controller.confirmStartupLanguage,
            child: Text(language.continueLabel),
          ),
        ),
      ),
    );
  }
}
