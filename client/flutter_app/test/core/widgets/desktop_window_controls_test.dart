import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/core/widgets/desktop_close_button.dart';
import 'package:innocence_flutter/core/widgets/desktop_resize_frame.dart';
import 'package:innocence_flutter/core/widgets/secondary_page_scaffold.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('desktop resize frame exposes and dispatches all eight edges',
      (tester) async {
    const channel = MethodChannel('innocence/desktop_widget');
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DesktopResizeFrame(
            child: ColoredBox(color: Colors.white),
          ),
        ),
      ),
    );

    const edges = <String>[
      'left',
      'right',
      'top',
      'bottom',
      'topLeft',
      'topRight',
      'bottomLeft',
      'bottomRight',
    ];
    for (final edge in edges) {
      await tester.tap(find.byKey(ValueKey('desktop-resize-$edge')));
      await tester.pump();
    }

    final resizeCalls =
        calls.where((call) => call.method == 'startWindowResize').toList();
    expect(resizeCalls, hasLength(edges.length));
    expect(
      resizeCalls.map((call) => (call.arguments as Map)['edge']).toList(),
      edges,
    );

    expect(
      tester
          .widget<MouseRegion>(
            find.byKey(const ValueKey('desktop-resize-left')),
          )
          .cursor,
      SystemMouseCursors.resizeLeftRight,
    );
    expect(
      tester
          .widget<MouseRegion>(
            find.byKey(const ValueKey('desktop-resize-topRight')),
          )
          .cursor,
      SystemMouseCursors.resizeUpRightDownLeft,
    );
  });

  testWidgets('desktop resize frame can be disabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DesktopResizeFrame(
            enabled: false,
            child: SizedBox.expand(),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('desktop-resize-left')), findsNothing);
  });

  testWidgets('window size controls stay visible with descending circle sizes',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topRight,
            child: DesktopWindowControls(),
          ),
        ),
      ),
    );

    expect(find.byTooltip('大画布'), findsOneWidget);
    expect(find.byTooltip('中画布'), findsOneWidget);
    expect(find.byTooltip('小画布'), findsOneWidget);

    final large =
        tester.getSize(find.byKey(const ValueKey('canvas-size-glyph-large')));
    final medium =
        tester.getSize(find.byKey(const ValueKey('canvas-size-glyph-medium')));
    final small =
        tester.getSize(find.byKey(const ValueKey('canvas-size-glyph-small')));
    expect(large.width, greaterThan(medium.width));
    expect(medium.width, greaterThan(small.width));

    await tester.tap(find.byKey(const ValueKey('canvas-size-large')));
    await tester.tap(find.byKey(const ValueKey('canvas-size-medium')));
    await tester.tap(find.byKey(const ValueKey('canvas-size-small')));
  });

  testWidgets('pinned secondary header stays visible while content scrolls',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SecondaryPageScaffold(
          backLabel: '返回',
          title: '统计中心',
          description: '固定工具栏',
          pinHeader: true,
          children: [SizedBox(height: 1800)],
        ),
      ),
    );

    final backButton = find.widgetWithText(OutlinedButton, '返回');
    final initialY = tester.getCenter(backButton).dy;
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('返回'), findsOneWidget);
    expect(tester.getCenter(backButton).dy, initialY);
  });
}
