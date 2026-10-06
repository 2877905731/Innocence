import 'dart:io';

import 'runtime_capabilities.dart';

class AppConfig {
  AppConfig._();

  // Also allows the shared tablet UI to be exercised on a host Flutter tester.
  static const String _targetPlatform =
      String.fromEnvironment('INNOCENCE_TARGET_PLATFORM');
  static RuntimeCapabilities get capabilities => RuntimeCapabilities(
        operatingSystem: _targetPlatform.isEmpty
            ? Platform.operatingSystem
            : _targetPlatform,
      );

  static const bool _offlineOnlyBuild =
      bool.fromEnvironment('INNOCENCE_OFFLINE_ONLY', defaultValue: false);

  // The Harmony online/device-slot contract is not enabled in this first build.
  static bool get offlineOnlyBuild =>
      _offlineOnlyBuild || capabilities.isHarmonyTablet;

  static const String _overrideBaseUrl =
      String.fromEnvironment('INNOCENCE_API_BASE_URL', defaultValue: '');

  static String get apiBaseUrl {
    if (offlineOnlyBuild) return '';
    if (_overrideBaseUrl.isNotEmpty) {
      return _normalizeBaseUrl(_overrideBaseUrl);
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/app/v1/';
    }
    return 'http://127.0.0.1:8080/api/app/v1/';
  }

  static String get deviceType => capabilities.deviceType;

  static String _normalizeBaseUrl(String rawBaseUrl) {
    final trimmed = rawBaseUrl.trim();
    final normalized = trimmed.endsWith('/') ? trimmed : '$trimmed/';
    if (normalized.contains('/api/')) {
      return normalized;
    }
    return '${normalized}api/app/v1/';
  }
}
