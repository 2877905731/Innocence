/// Presentation and native integration are separate platform capabilities.
class RuntimeCapabilities {
  const RuntimeCapabilities({required this.operatingSystem});

  final String operatingSystem;

  bool get isHarmonyTablet =>
      operatingSystem == 'ohos' || operatingSystem == 'harmonyos';
  bool get isAndroidPhone => operatingSystem == 'android';
  bool get supportsDesktopWindow => operatingSystem == 'windows';
  bool get usesPcLayout => supportsDesktopWindow || isHarmonyTablet;
  bool get restoresLocalWorkspace => isAndroidPhone || isHarmonyTablet;

  String get deviceType => isHarmonyTablet ? 'harmonyos' : operatingSystem;
}
