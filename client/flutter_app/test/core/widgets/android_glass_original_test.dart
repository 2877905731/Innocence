import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/widgets/glass_motion_backdrop.dart';
import 'package:innocence_flutter/core/widgets/glass_refractive_surface.dart';

void main() {
  testWidgets('Android light scene matches the original pre-0118 appearance',
      (tester) async {
    tester.view.physicalSize = const Size(411, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    GlassLightScene? scene;
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
      data: const MediaQueryData(
          size: Size(411, 915), devicePixelRatio: 1, disableAnimations: true),
      child: GlassMotionBackdrop(child: Builder(builder: (context) {
        scene = GlassLightSceneScope.maybeOf(context);
        return const SizedBox.expand();
      })),
    )));
    await tester.pump();
    // Captured from 4417cdf^, before the Harmony edge fix changed Android.
    await expectLater(
        scene!.image!, matchesGoldenFile('goldens/android_glass_pre_0118.png'));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  }, skip: !AppConfig.capabilities.isAndroidPhone);
}
