import 'package:innocence_flutter/core/layout/desktop_presentation.dart';

enum SettingsPageComposition {
  splitPane,
  groupedForm,
  listDetail,
}

class SettingsPresentationPolicy {
  SettingsPresentationPolicy._();

  static SettingsPageComposition resolve(DesktopPresentationTier tier) {
    return switch (tier) {
      DesktopPresentationTier.large => SettingsPageComposition.splitPane,
      DesktopPresentationTier.medium => SettingsPageComposition.groupedForm,
      DesktopPresentationTier.small => SettingsPageComposition.listDetail,
    };
  }
}
