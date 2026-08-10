import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:innocence_flutter/core/layout/desktop_presentation.dart';

void main() {
  group('DesktopPresentationPolicy', () {
    test('resolves the initial tier from both width and height', () {
      expect(
        DesktopPresentationPolicy.resolveTier(const Size(1360, 860)),
        DesktopPresentationTier.large,
      );
      expect(
        DesktopPresentationPolicy.resolveTier(const Size(1180, 700)),
        DesktopPresentationTier.medium,
      );
      expect(
        DesktopPresentationPolicy.resolveTier(const Size(920, 760)),
        DesktopPresentationTier.medium,
      );
      expect(
        DesktopPresentationPolicy.resolveTier(const Size(460, 700)),
        DesktopPresentationTier.small,
      );
    });

    test('keeps large tier inside the 32px exit hysteresis', () {
      expect(
        DesktopPresentationPolicy.resolveTier(
          const Size(1150, 690),
          previousTier: DesktopPresentationTier.large,
        ),
        DesktopPresentationTier.large,
      );
      expect(
        DesktopPresentationPolicy.resolveTier(
          const Size(1147, 688),
          previousTier: DesktopPresentationTier.large,
        ),
        DesktopPresentationTier.medium,
      );
    });

    test('keeps medium tier inside the 32px exit hysteresis', () {
      expect(
        DesktopPresentationPolicy.resolveTier(
          const Size(730, 590),
          previousTier: DesktopPresentationTier.medium,
        ),
        DesktopPresentationTier.medium,
      );
      expect(
        DesktopPresentationPolicy.resolveTier(
          const Size(727, 620),
          previousTier: DesktopPresentationTier.medium,
        ),
        DesktopPresentationTier.small,
      );
    });

    test('can jump directly from small to large', () {
      expect(
        DesktopPresentationPolicy.resolveTier(
          const Size(1400, 900),
          previousTier: DesktopPresentationTier.small,
        ),
        DesktopPresentationTier.large,
      );
    });

    test('maps tiers to density and navigation contracts', () {
      final large = DesktopPresentationPolicy.resolveCanvas(
        const Size(1360, 860),
        reduceMotion: false,
      );
      final medium = DesktopPresentationPolicy.resolveCanvas(
        const Size(920, 760),
        reduceMotion: true,
      );
      final small = DesktopPresentationPolicy.resolveCanvas(
        const Size(460, 700),
        reduceMotion: false,
      );

      expect(large.defaultDensity, ComponentPresentationDensity.full);
      expect(large.navigation, NavigationPresentation.rail);
      expect(large.showContextPane, isTrue);
      expect(
        medium.defaultDensity,
        ComponentPresentationDensity.comfortable,
      );
      expect(medium.navigation, NavigationPresentation.compactRail);
      expect(medium.reduceMotion, isTrue);
      expect(small.defaultDensity, ComponentPresentationDensity.compact);
      expect(small.navigation, NavigationPresentation.bottomBar);
    });

    test('keeps Focus Orb outside the canvas tier system', () {
      const orb = DesktopPresentationSpec.orb(reduceMotion: true);

      expect(DesktopPresentationPolicy.focusOrbSize, const Size.square(72));
      expect(orb.surface, DesktopWindowSurface.orb);
      expect(orb.tier, isNull);
      expect(orb.defaultDensity, ComponentPresentationDensity.glance);
      expect(orb.navigation, NavigationPresentation.none);
      expect(orb.reduceMotion, isTrue);
    });
  });
}
