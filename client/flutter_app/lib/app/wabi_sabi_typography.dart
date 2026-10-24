import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bundled display faces: independent of the device's installed system fonts.
abstract final class WabiSabiTypography {
  static const latinFamily = 'CrimsonText';
  static const chineseFamily = 'NotoSerifSC';
  static const fallback = [chineseFamily];

  static void registerLicenses() {
    LicenseRegistry.addLicense(() async* {
      for (final (name, asset) in [
        ('Crimson Text', 'assets/fonts/crimson_text/OFL.txt'),
        ('Noto Serif SC', 'assets/fonts/noto_serif_sc/OFL.txt'),
      ]) {
        yield LicenseEntryWithLineBreaks(
            [name], await rootBundle.loadString(asset));
      }
    });
  }

  static TextStyle heading(TextStyle base) => base.copyWith(
        fontFamily: latinFamily,
        fontFamilyFallback: fallback,
      );

  static TextStyle slogan(TextStyle base) => heading(base).copyWith(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        height: 1.12,
        letterSpacing: 0.3,
      );
}
