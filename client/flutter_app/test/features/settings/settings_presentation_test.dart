import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/core/layout/desktop_presentation.dart';
import 'package:innocence_flutter/features/settings/presentation/settings_presentation.dart';

void main() {
  test('large settings use split navigation and form panes', () {
    expect(
      SettingsPresentationPolicy.resolve(DesktopPresentationTier.large),
      SettingsPageComposition.splitPane,
    );
  });

  test('medium settings use grouped navigation above one form', () {
    expect(
      SettingsPresentationPolicy.resolve(DesktopPresentationTier.medium),
      SettingsPageComposition.groupedForm,
    );
  });

  test('small settings use list to detail navigation', () {
    expect(
      SettingsPresentationPolicy.resolve(DesktopPresentationTier.small),
      SettingsPageComposition.listDetail,
    );
  });
}
