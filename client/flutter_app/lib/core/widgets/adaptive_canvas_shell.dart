import 'package:flutter/material.dart';

import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/layout/desktop_presentation.dart';
import 'package:innocence_flutter/core/widgets/desktop_close_button.dart';
import 'package:innocence_flutter/core/widgets/desktop_drag_region.dart';
import 'package:innocence_flutter/core/widgets/desktop_resize_frame.dart';
import 'package:innocence_flutter/core/widgets/wabi_sabi_paper.dart';

@immutable
class AdaptiveCanvasDestination {
  const AdaptiveCanvasDestination({
    required this.id,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badgeCount = 0,
    this.utility = false,
    this.smallPrimary = false,
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final int badgeCount;
  final bool utility;
  final bool smallPrimary;
}

class AdaptiveCanvasShell extends StatelessWidget {
  const AdaptiveCanvasShell({
    super.key,
    required this.visualTheme,
    required this.destinations,
    required this.selectedDestinationId,
    required this.onDestinationSelected,
    required this.pageTitle,
    required this.userDisplayName,
    required this.bodyBuilder,
    this.pageSubtitle,
    this.syncLabel,
    this.isRefreshing = false,
    this.onRefresh,
    this.onOpenFocusOrb,
  });

  final List<AdaptiveCanvasDestination> destinations;
  final AppVisualTheme visualTheme;
  final String selectedDestinationId;
  final ValueChanged<String> onDestinationSelected;
  final String pageTitle;
  final String? pageSubtitle;
  final String userDisplayName;
  final String? syncLabel;
  final bool isRefreshing;
  final VoidCallback? onRefresh;
  final VoidCallback? onOpenFocusOrb;
  final Widget Function(
    BuildContext context,
    DesktopPresentationSpec spec,
  ) bodyBuilder;

  @override
  Widget build(BuildContext context) {
    return DesktopPresentationLayout(
      surface: DesktopWindowSurface.canvas,
      builder: (context, spec) {
        final palette = _CanvasPalette.of(context, visualTheme);
        final body = bodyBuilder(context, spec);
        final content = SafeArea(
          child: switch (spec.navigation) {
            NavigationPresentation.rail ||
            NavigationPresentation.compactRail =>
              _RailCanvas(
                palette: palette,
                spec: spec,
                destinations: destinations,
                selectedDestinationId: selectedDestinationId,
                onDestinationSelected: onDestinationSelected,
                pageTitle: pageTitle,
                pageSubtitle: pageSubtitle,
                userDisplayName: userDisplayName,
                syncLabel: syncLabel,
                isRefreshing: isRefreshing,
                onRefresh: onRefresh,
                onOpenFocusOrb: onOpenFocusOrb,
                body: body,
              ),
            NavigationPresentation.bottomBar => _SmallCanvas(
                palette: palette,
                destinations: destinations,
                selectedDestinationId: selectedDestinationId,
                onDestinationSelected: onDestinationSelected,
                pageTitle: pageTitle,
                userDisplayName: userDisplayName,
                isRefreshing: isRefreshing,
                onRefresh: onRefresh,
                onOpenFocusOrb: onOpenFocusOrb,
                body: body,
              ),
            NavigationPresentation.none => body,
          },
        );

        final themedContent = switch (visualTheme) {
          AppVisualTheme.wabiSabi =>
            WabiSabiPaper(color: palette.background, child: content),
          AppVisualTheme.glass => DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF173B91),
                    Color(0xFF5424B6),
                    Color(0xFFBE4D9B),
                  ],
                ),
              ),
              child: content,
            ),
          _ => content,
        };
        return Scaffold(
          backgroundColor: palette.background,
          body: DesktopResizeFrame(child: themedContent),
        );
      },
    );
  }
}

class _RailCanvas extends StatelessWidget {
  const _RailCanvas({
    required this.palette,
    required this.spec,
    required this.destinations,
    required this.selectedDestinationId,
    required this.onDestinationSelected,
    required this.pageTitle,
    required this.pageSubtitle,
    required this.userDisplayName,
    required this.syncLabel,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onOpenFocusOrb,
    required this.body,
  });

  final _CanvasPalette palette;
  final DesktopPresentationSpec spec;
  final List<AdaptiveCanvasDestination> destinations;
  final String selectedDestinationId;
  final ValueChanged<String> onDestinationSelected;
  final String pageTitle;
  final String? pageSubtitle;
  final String userDisplayName;
  final String? syncLabel;
  final bool isRefreshing;
  final VoidCallback? onRefresh;
  final VoidCallback? onOpenFocusOrb;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final primary = destinations.where((item) => !item.utility).toList();
    final utilities = destinations.where((item) => item.utility).toList();
    final large = spec.tier == DesktopPresentationTier.large;

    return Row(
      children: [
        Container(
          width: large ? 80 : 68,
          color: palette.navigation,
          child: Column(
            children: [
              const SizedBox(height: 14),
              _BrandMark(palette: palette),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: primary.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _RailButton(
                    palette: palette,
                    destination: primary[index],
                    selected: primary[index].id == selectedDestinationId,
                    onPressed: () => onDestinationSelected(primary[index].id),
                  ),
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                color: palette.rule,
              ),
              const SizedBox(height: 10),
              ...utilities.map(
                (destination) => Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                  child: _RailButton(
                    palette: palette,
                    destination: destination,
                    selected: destination.id == selectedDestinationId,
                    onPressed: () => onDestinationSelected(destination.id),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _CommandBar(
                palette: palette,
                pageTitle: pageTitle,
                pageSubtitle: pageSubtitle,
                userDisplayName: userDisplayName,
                syncLabel: syncLabel,
                isRefreshing: isRefreshing,
                onRefresh: onRefresh,
                onOpenFocusOrb: onOpenFocusOrb,
              ),
              Container(height: 1, color: palette.rule),
              Expanded(child: body),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallCanvas extends StatelessWidget {
  const _SmallCanvas({
    required this.palette,
    required this.destinations,
    required this.selectedDestinationId,
    required this.onDestinationSelected,
    required this.pageTitle,
    required this.userDisplayName,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onOpenFocusOrb,
    required this.body,
  });

  final _CanvasPalette palette;
  final List<AdaptiveCanvasDestination> destinations;
  final String selectedDestinationId;
  final ValueChanged<String> onDestinationSelected;
  final String pageTitle;
  final String userDisplayName;
  final bool isRefreshing;
  final VoidCallback? onRefresh;
  final VoidCallback? onOpenFocusOrb;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final smallPrimary =
        destinations.where((item) => item.smallPrimary).take(4).toList();
    final overflow = destinations.where((item) => !item.smallPrimary).toList();

    return Column(
      children: [
        SizedBox(
          height: 58,
          child: Stack(
            children: [
              const Positioned.fill(child: DesktopDragRegion()),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      _UserMark(
                        palette: palette,
                        displayName: userDisplayName,
                        compact: true,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: IgnorePointer(
                          child: Text(
                            pageTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (onRefresh != null)
                        IconButton(
                          tooltip: '刷新',
                          onPressed: isRefreshing ? null : onRefresh,
                          icon: isRefreshing
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded),
                        ),
                      if (onOpenFocusOrb != null)
                        IconButton(
                          tooltip: '专注悬浮球',
                          onPressed: onOpenFocusOrb,
                          icon: const Icon(Icons.adjust_rounded),
                        ),
                      PopupMenuButton<String>(
                        tooltip: '更多',
                        onSelected: onDestinationSelected,
                        itemBuilder: (context) => overflow
                            .map(
                              (destination) => PopupMenuItem<String>(
                                value: destination.id,
                                child: Row(
                                  children: [
                                    Icon(destination.icon, size: 20),
                                    const SizedBox(width: 12),
                                    Text(destination.label),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        icon: const Icon(Icons.more_horiz_rounded),
                      ),
                      const DesktopWindowControls(
                        compact: true,
                        showMinimize: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: palette.rule),
        Expanded(child: body),
        Container(
          height: 66,
          decoration: BoxDecoration(
            color: palette.navigation,
            border: Border(top: BorderSide(color: palette.rule)),
          ),
          child: Row(
            children: smallPrimary
                .map(
                  (destination) => Expanded(
                    child: _BottomButton(
                      palette: palette,
                      destination: destination,
                      selected: destination.id == selectedDestinationId,
                      onPressed: () => onDestinationSelected(destination.id),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _CommandBar extends StatelessWidget {
  const _CommandBar({
    required this.palette,
    required this.pageTitle,
    required this.pageSubtitle,
    required this.userDisplayName,
    required this.syncLabel,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onOpenFocusOrb,
  });

  final _CanvasPalette palette;
  final String pageTitle;
  final String? pageSubtitle;
  final String userDisplayName;
  final String? syncLabel;
  final bool isRefreshing;
  final VoidCallback? onRefresh;
  final VoidCallback? onOpenFocusOrb;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Stack(
        children: [
          const Positioned.fill(child: DesktopDragRegion()),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: IgnorePointer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pageTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.ink,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                          if (pageSubtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              pageSubtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (syncLabel != null) ...[
                    _SyncStatus(palette: palette, label: syncLabel!),
                    const SizedBox(width: 10),
                  ],
                  if (onRefresh != null)
                    IconButton(
                      tooltip: '刷新',
                      onPressed: isRefreshing ? null : onRefresh,
                      icon: isRefreshing
                          ? const SizedBox.square(
                              dimension: 17,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                    ),
                  if (onOpenFocusOrb != null)
                    IconButton(
                      tooltip: '专注悬浮球',
                      onPressed: onOpenFocusOrb,
                      icon: const Icon(Icons.adjust_rounded),
                    ),
                  const SizedBox(width: 6),
                  _UserMark(
                    palette: palette,
                    displayName: userDisplayName,
                    compact: false,
                  ),
                  const SizedBox(width: 10),
                  const DesktopWindowControls(compact: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.palette});

  final _CanvasPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.isGlass ? const Color(0x24FFFFFF) : palette.ink,
        border: Border.all(
          color: palette.isGlass ? const Color(0x52FFFFFF) : palette.ink,
        ),
        borderRadius: BorderRadius.circular(palette.isGlass ? 12 : 0),
      ),
      child: Text(
        'I',
        style: TextStyle(
          color: palette.isGlass ? palette.ink : palette.navigation,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _UserMark extends StatelessWidget {
  const _UserMark({
    required this.palette,
    required this.displayName,
    required this.compact,
  });

  final _CanvasPalette palette;
  final String displayName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final normalized = displayName.trim();
    final initial = normalized.isEmpty ? 'I' : normalized.characters.first;
    final size = compact ? 34.0 : 40.0;
    return Tooltip(
      message: normalized.isEmpty ? 'Innocence' : normalized,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.accentSoft,
          border: Border.all(color: palette.rule),
        ),
        child: Text(
          initial.toUpperCase(),
          style: TextStyle(
            color: palette.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SyncStatus extends StatelessWidget {
  const _SyncStatus({required this.palette, required this.label});

  final _CanvasPalette palette;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.rule),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, color: palette.success),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: palette.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.palette,
    required this.destination,
    required this.selected,
    required this.onPressed,
  });

  final _CanvasPalette palette;
  final AdaptiveCanvasDestination destination;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: destination.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (selected)
                  Positioned(
                    left: 0,
                    top: 9,
                    bottom: 9,
                    child: Container(width: 3, color: palette.accent),
                  ),
                Icon(
                  selected
                      ? destination.selectedIcon ?? destination.icon
                      : destination.icon,
                  size: 22,
                  color: selected ? palette.ink : palette.muted,
                ),
                if (destination.badgeCount > 0)
                  Positioned(
                    top: 8,
                    right: 7,
                    child: Container(
                      width: 8,
                      height: 8,
                      color: palette.danger,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.palette,
    required this.destination,
    required this.selected,
    required this.onPressed,
  });

  final _CanvasPalette palette;
  final AdaptiveCanvasDestination destination;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                selected
                    ? destination.selectedIcon ?? destination.icon
                    : destination.icon,
                color: selected ? palette.ink : palette.muted,
                size: 21,
              ),
              if (destination.badgeCount > 0)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(width: 7, height: 7, color: palette.danger),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            destination.label,
            maxLines: 1,
            style: TextStyle(
              color: selected ? palette.ink : palette.muted,
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class _CanvasPalette {
  const _CanvasPalette({
    required this.background,
    required this.navigation,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.rule,
    required this.accent,
    required this.accentSoft,
    required this.success,
    required this.danger,
    required this.isGlass,
  });

  final Color background;
  final Color navigation;
  final Color surface;
  final Color ink;
  final Color muted;
  final Color rule;
  final Color accent;
  final Color accentSoft;
  final Color success;
  final Color danger;
  final bool isGlass;

  static _CanvasPalette of(
    BuildContext context,
    AppVisualTheme visualTheme,
  ) {
    final tokens = AppVisualTokens.of(visualTheme);
    final colors = Theme.of(context).colorScheme;
    final glass = visualTheme == AppVisualTheme.glass;
    return _CanvasPalette(
      background: glass ? const Color(0xFF173B91) : tokens.canvas,
      navigation: glass ? const Color(0x42101B38) : tokens.softPanel,
      surface: glass ? const Color(0x32101D3B) : tokens.panel,
      ink: tokens.ink,
      muted: tokens.muted,
      rule: glass ? const Color(0x32FFFFFF) : tokens.line,
      accent: tokens.accent,
      accentSoft: Color.alphaBlend(
        tokens.accent.withValues(alpha: tokens.isDark ? 0.24 : 0.18),
        tokens.softPanel,
      ),
      success: colors.tertiary,
      danger: colors.error,
      isGlass: glass,
    );
  }
}
