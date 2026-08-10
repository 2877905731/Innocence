import 'package:flutter/material.dart';

enum DesktopWindowSurface {
  auth,
  canvas,
  orb,
}

enum DesktopPresentationTier {
  large,
  medium,
  small,
}

enum ComponentPresentationDensity {
  full,
  comfortable,
  compact,
  glance,
}

enum NavigationPresentation {
  rail,
  compactRail,
  bottomBar,
  none,
}

@immutable
class DesktopPresentationSpec {
  const DesktopPresentationSpec({
    required this.surface,
    required this.tier,
    required this.defaultDensity,
    required this.navigation,
    required this.showContextPane,
    required this.reduceMotion,
  });

  final DesktopWindowSurface surface;
  final DesktopPresentationTier? tier;
  final ComponentPresentationDensity defaultDensity;
  final NavigationPresentation navigation;
  final bool showContextPane;
  final bool reduceMotion;

  factory DesktopPresentationSpec.canvas({
    required DesktopPresentationTier tier,
    required bool reduceMotion,
  }) {
    switch (tier) {
      case DesktopPresentationTier.large:
        return DesktopPresentationSpec(
          surface: DesktopWindowSurface.canvas,
          tier: tier,
          defaultDensity: ComponentPresentationDensity.full,
          navigation: NavigationPresentation.rail,
          showContextPane: true,
          reduceMotion: reduceMotion,
        );
      case DesktopPresentationTier.medium:
        return DesktopPresentationSpec(
          surface: DesktopWindowSurface.canvas,
          tier: tier,
          defaultDensity: ComponentPresentationDensity.comfortable,
          navigation: NavigationPresentation.compactRail,
          showContextPane: false,
          reduceMotion: reduceMotion,
        );
      case DesktopPresentationTier.small:
        return DesktopPresentationSpec(
          surface: DesktopWindowSurface.canvas,
          tier: tier,
          defaultDensity: ComponentPresentationDensity.compact,
          navigation: NavigationPresentation.bottomBar,
          showContextPane: false,
          reduceMotion: reduceMotion,
        );
    }
  }

  factory DesktopPresentationSpec.auth({
    required DesktopPresentationTier tier,
    required bool reduceMotion,
  }) {
    return DesktopPresentationSpec(
      surface: DesktopWindowSurface.auth,
      tier: tier,
      defaultDensity: switch (tier) {
        DesktopPresentationTier.large => ComponentPresentationDensity.full,
        DesktopPresentationTier.medium =>
          ComponentPresentationDensity.comfortable,
        DesktopPresentationTier.small => ComponentPresentationDensity.compact,
      },
      navigation: NavigationPresentation.none,
      showContextPane: tier == DesktopPresentationTier.large,
      reduceMotion: reduceMotion,
    );
  }

  const DesktopPresentationSpec.orb({required bool reduceMotion})
      : surface = DesktopWindowSurface.orb,
        tier = null,
        defaultDensity = ComponentPresentationDensity.glance,
        navigation = NavigationPresentation.none,
        showContextPane = false,
        reduceMotion = reduceMotion;
}

class DesktopPresentationPolicy {
  DesktopPresentationPolicy._();

  static const Size minimumCanvasSize = Size(380, 520);
  static const Size mediumThreshold = Size(760, 620);
  static const Size largeThreshold = Size(1180, 720);
  static const double hysteresis = 32;

  static DesktopPresentationTier resolveTier(
    Size viewport, {
    DesktopPresentationTier? previousTier,
  }) {
    if (previousTier == null) {
      return _resolveWithoutHistory(viewport);
    }

    switch (previousTier) {
      case DesktopPresentationTier.large:
        final remainsLarge =
            viewport.width >= largeThreshold.width - hysteresis &&
                viewport.height >= largeThreshold.height - hysteresis;
        return remainsLarge
            ? DesktopPresentationTier.large
            : _resolveWithoutHistory(viewport);
      case DesktopPresentationTier.medium:
        if (_meets(viewport, largeThreshold)) {
          return DesktopPresentationTier.large;
        }
        final remainsMedium =
            viewport.width >= mediumThreshold.width - hysteresis &&
                viewport.height >= mediumThreshold.height - hysteresis;
        return remainsMedium
            ? DesktopPresentationTier.medium
            : DesktopPresentationTier.small;
      case DesktopPresentationTier.small:
        if (_meets(viewport, largeThreshold)) {
          return DesktopPresentationTier.large;
        }
        return _meets(viewport, mediumThreshold)
            ? DesktopPresentationTier.medium
            : DesktopPresentationTier.small;
    }
  }

  static DesktopPresentationSpec resolveCanvas(
    Size viewport, {
    DesktopPresentationTier? previousTier,
    required bool reduceMotion,
  }) {
    return DesktopPresentationSpec.canvas(
      tier: resolveTier(viewport, previousTier: previousTier),
      reduceMotion: reduceMotion,
    );
  }

  static DesktopPresentationTier _resolveWithoutHistory(Size viewport) {
    if (_meets(viewport, largeThreshold)) {
      return DesktopPresentationTier.large;
    }
    if (_meets(viewport, mediumThreshold)) {
      return DesktopPresentationTier.medium;
    }
    return DesktopPresentationTier.small;
  }

  static bool _meets(Size viewport, Size threshold) {
    return viewport.width >= threshold.width &&
        viewport.height >= threshold.height;
  }
}

class DesktopPresentationLayout extends StatefulWidget {
  const DesktopPresentationLayout({
    super.key,
    required this.surface,
    required this.builder,
  });

  final DesktopWindowSurface surface;
  final Widget Function(
    BuildContext context,
    DesktopPresentationSpec spec,
  ) builder;

  @override
  State<DesktopPresentationLayout> createState() =>
      _DesktopPresentationLayoutState();
}

class _DesktopPresentationLayoutState extends State<DesktopPresentationLayout> {
  DesktopPresentationTier? _previousTier;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion = mediaQuery?.disableAnimations ?? false;
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        final spec = switch (widget.surface) {
          DesktopWindowSurface.orb =>
            DesktopPresentationSpec.orb(reduceMotion: reduceMotion),
          DesktopWindowSurface.auth => _resolveAuth(viewport, reduceMotion),
          DesktopWindowSurface.canvas => _resolveCanvas(viewport, reduceMotion),
        };

        return DesktopPresentation._(
          spec: spec,
          child: widget.builder(context, spec),
        );
      },
    );
  }

  DesktopPresentationSpec _resolveAuth(Size viewport, bool reduceMotion) {
    final tier = DesktopPresentationPolicy.resolveTier(
      viewport,
      previousTier: _previousTier,
    );
    _previousTier = tier;
    return DesktopPresentationSpec.auth(
      tier: tier,
      reduceMotion: reduceMotion,
    );
  }

  DesktopPresentationSpec _resolveCanvas(Size viewport, bool reduceMotion) {
    final spec = DesktopPresentationPolicy.resolveCanvas(
      viewport,
      previousTier: _previousTier,
      reduceMotion: reduceMotion,
    );
    _previousTier = spec.tier;
    return spec;
  }
}

class DesktopPresentation extends InheritedWidget {
  const DesktopPresentation._({
    required this.spec,
    required super.child,
  });

  final DesktopPresentationSpec spec;

  static DesktopPresentationSpec of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<DesktopPresentation>();
    assert(scope != null, 'DesktopPresentationLayout is missing above context.');
    return scope!.spec;
  }

  static DesktopPresentationSpec? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DesktopPresentation>()
        ?.spec;
  }

  @override
  bool updateShouldNotify(DesktopPresentation oldWidget) {
    return spec.surface != oldWidget.spec.surface ||
        spec.tier != oldWidget.spec.tier ||
        spec.defaultDensity != oldWidget.spec.defaultDensity ||
        spec.navigation != oldWidget.spec.navigation ||
        spec.showContextPane != oldWidget.spec.showContextPane ||
        spec.reduceMotion != oldWidget.spec.reduceMotion;
  }
}
