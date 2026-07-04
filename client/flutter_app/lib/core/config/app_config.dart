import 'dart:io';

class AppConfig {
  AppConfig._();

  static const String _overrideBaseUrl =
      String.fromEnvironment('INNOCENCE_API_BASE_URL', defaultValue: '');

  static String get apiBaseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _normalizeBaseUrl(_overrideBaseUrl);
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/app/v1/';
    }
    return 'http://127.0.0.1:8080/api/app/v1/';
  }

  static String get deviceType {
    if (Platform.isWindows) {
      return 'windows';
    }
    if (Platform.isAndroid) {
      return 'android';
    }
    return 'windows';
  }

  static String _normalizeBaseUrl(String rawBaseUrl) {
    final trimmed = rawBaseUrl.trim();
    final normalized = trimmed.endsWith('/') ? trimmed : '$trimmed/';
    if (normalized.contains('/api/')) {
      return normalized;
    }
    return '${normalized}api/app/v1/';
  }
}
