import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/widgets/themed_dialog.dart';

void main() {
  testWidgets('modal draft survives a nested dialog and returns its input',
      (tester) async {
    for (final visualTheme in [
      AppVisualTheme.glass,
      AppVisualTheme.minimalism,
    ]) {
      String? result;
      await tester.pumpWidget(MaterialApp(
        theme: AppVisualTokens.of(visualTheme).toThemeData(visualTheme),
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await showThemedDialog<String>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const _DraftEditor(),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Focus draft');
      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.text('Nested'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back to editor'));
      await tester.pumpAndSettle();
      expect(find.text('Focus draft'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(result, 'Focus draft');
      expect(find.byType(AlertDialog), findsNothing);
    }
  });
}

class _DraftEditor extends StatefulWidget {
  const _DraftEditor();

  @override
  State<_DraftEditor> createState() => _DraftEditorState();
}

class _DraftEditorState extends State<_DraftEditor> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Draft editor'),
      content: TextField(controller: _controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => showThemedDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Nested editor'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to editor'),
                ),
              ],
            ),
          ),
          child: const Text('Nested'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
