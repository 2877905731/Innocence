import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  simplifiedChinese,
  english,
}

AppLanguage appLanguageFromStorage(String? value) {
  switch (value) {
    case 'en_US':
      return AppLanguage.english;
    case 'zh_CN':
    default:
      return AppLanguage.simplifiedChinese;
  }
}

extension AppLanguageX on AppLanguage {
  String get storageValue {
    switch (this) {
      case AppLanguage.english:
        return 'en_US';
      case AppLanguage.simplifiedChinese:
        return 'zh_CN';
    }
  }

  Locale get locale {
    switch (this) {
      case AppLanguage.english:
        return const Locale('en', 'US');
      case AppLanguage.simplifiedChinese:
        return const Locale('zh', 'CN');
    }
  }

  bool get isChinese => this == AppLanguage.simplifiedChinese;

  String get label {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.simplifiedChinese:
        return '\u7b80\u4f53\u4e2d\u6587';
    }
  }

  String get startupTitle {
    switch (this) {
      case AppLanguage.english:
        return 'Choose display language';
      case AppLanguage.simplifiedChinese:
        return '\u9009\u62e9\u663e\u793a\u8bed\u8a00';
    }
  }

  String get startupDescription {
    switch (this) {
      case AppLanguage.english:
        return 'Choose the display language for the first launch.';
      case AppLanguage.simplifiedChinese:
        return '\u9996\u6b21\u542f\u52a8\u524d\uff0c\u8bf7\u9009\u62e9\u663e\u793a\u8bed\u8a00\u3002';
    }
  }

  String get continueLabel {
    switch (this) {
      case AppLanguage.english:
        return 'Continue';
      case AppLanguage.simplifiedChinese:
        return '\u8fdb\u5165\u8f6f\u4ef6';
    }
  }

  String get launchMessage {
    switch (this) {
      case AppLanguage.english:
        return 'Restoring the current device session...';
      case AppLanguage.simplifiedChinese:
        return '\u6b63\u5728\u6062\u590d\u5f53\u524d\u8bbe\u5907\u4f1a\u8bdd...';
    }
  }

  String get authPasswordLoginTitle {
    switch (this) {
      case AppLanguage.english:
        return 'Password login';
      case AppLanguage.simplifiedChinese:
        return '\u5bc6\u7801\u767b\u5f55';
    }
  }

  String get authCodeLoginTitle {
    switch (this) {
      case AppLanguage.english:
        return 'Code login';
      case AppLanguage.simplifiedChinese:
        return '\u9a8c\u8bc1\u7801\u767b\u5f55';
    }
  }

  String get authRegisterTitle {
    switch (this) {
      case AppLanguage.english:
        return 'Email register';
      case AppLanguage.simplifiedChinese:
        return '\u90ae\u7bb1\u6ce8\u518c';
    }
  }

  String get authPasswordLoginDescription {
    switch (this) {
      case AppLanguage.english:
        return 'Use email and password for your usual sign-in flow.';
      case AppLanguage.simplifiedChinese:
        return '\u4f7f\u7528\u90ae\u7bb1\u548c\u5bc6\u7801\u5b8c\u6210\u65e5\u5e38\u767b\u5f55\u3002';
    }
  }

  String get authCodeLoginDescription {
    switch (this) {
      case AppLanguage.english:
        return 'Receive a code by email for quick access on this device.';
      case AppLanguage.simplifiedChinese:
        return '\u901a\u8fc7\u90ae\u7bb1\u9a8c\u8bc1\u7801\u5feb\u901f\u767b\u5f55\u5f53\u524d\u8bbe\u5907\u3002';
    }
  }

  String get authRegisterDescription {
    switch (this) {
      case AppLanguage.english:
        return 'Create a new account and sign in right away.';
      case AppLanguage.simplifiedChinese:
        return '\u521b\u5efa\u65b0\u8d26\u53f7\u5e76\u76f4\u63a5\u8fdb\u5165\u8f6f\u4ef6\u3002';
    }
  }

  String get enterInnocenceLabel {
    switch (this) {
      case AppLanguage.english:
        return 'Enter Innocence';
      case AppLanguage.simplifiedChinese:
        return '\u8fdb\u5165 Innocence';
    }
  }

  String get authCodeSubmitLabel {
    switch (this) {
      case AppLanguage.english:
        return 'Sign in with code';
      case AppLanguage.simplifiedChinese:
        return '\u9a8c\u8bc1\u7801\u767b\u5f55';
    }
  }

  String get authRegisterSubmitLabel {
    switch (this) {
      case AppLanguage.english:
        return 'Register and sign in';
      case AppLanguage.simplifiedChinese:
        return '\u6ce8\u518c\u5e76\u767b\u5f55';
    }
  }

  String cooldownLabel(int seconds) {
    switch (this) {
      case AppLanguage.english:
        return 'Retry in $seconds s';
      case AppLanguage.simplifiedChinese:
        return '$seconds \u79d2\u540e\u91cd\u8bd5';
    }
  }

  String get sendRegisterCodeLabel {
    switch (this) {
      case AppLanguage.english:
        return 'Send register code';
      case AppLanguage.simplifiedChinese:
        return '\u53d1\u9001\u6ce8\u518c\u9a8c\u8bc1\u7801';
    }
  }

  String get sendLoginCodeLabel {
    switch (this) {
      case AppLanguage.english:
        return 'Send login code';
      case AppLanguage.simplifiedChinese:
        return '\u53d1\u9001\u767b\u5f55\u9a8c\u8bc1\u7801';
    }
  }

  String get invalidEmailPrompt {
    switch (this) {
      case AppLanguage.english:
        return 'Please enter a valid email first.';
      case AppLanguage.simplifiedChinese:
        return '\u8bf7\u5148\u8f93\u5165\u6b63\u786e\u7684\u90ae\u7bb1\u5730\u5740\u3002';
    }
  }

  String get verificationCodeSentPrompt {
    switch (this) {
      case AppLanguage.english:
        return 'Verification code sent. Please check your inbox.';
      case AppLanguage.simplifiedChinese:
        return '\u9a8c\u8bc1\u7801\u5df2\u53d1\u9001\uff0c\u8bf7\u67e5\u770b\u90ae\u7bb1\u3002';
    }
  }

  String get verificationCodeFailedPrompt {
    switch (this) {
      case AppLanguage.english:
        return 'Failed to send the verification code.';
      case AppLanguage.simplifiedChinese:
        return '\u53d1\u9001\u9a8c\u8bc1\u7801\u5931\u8d25\u3002';
    }
  }

  String get androidLabel {
    switch (this) {
      case AppLanguage.english:
        return 'Android';
      case AppLanguage.simplifiedChinese:
        return '\u5b89\u5353';
    }
  }

  String get windowsLabel {
    switch (this) {
      case AppLanguage.english:
        return 'Windows';
      case AppLanguage.simplifiedChinese:
        return 'Windows';
    }
  }
}

class AppLanguageController extends ChangeNotifier {
  AppLanguageController(this._preferences);

  final SharedPreferences _preferences;

  static const String _languageKey = 'app.language';
  static const String _startupConfirmedKey = 'app.language.startup_confirmed';

  bool _initialized = false;
  bool _startupConfirmed = false;
  AppLanguage _currentLanguage = AppLanguage.simplifiedChinese;

  bool get initialized => _initialized;
  bool get startupConfirmed => _startupConfirmed;
  AppLanguage get currentLanguage => _currentLanguage;
  Locale get locale => _currentLanguage.locale;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _currentLanguage =
        appLanguageFromStorage(_preferences.getString(_languageKey));
    _startupConfirmed =
        _preferences.getBool(_startupConfirmedKey) ?? false;
    _initialized = true;
    notifyListeners();
  }

  void previewLanguage(AppLanguage language) {
    if (_currentLanguage == language) {
      return;
    }
    _currentLanguage = language;
    notifyListeners();
  }

  Future<void> updateLanguage(
    AppLanguage language, {
    bool confirmStartup = true,
  }) async {
    final languageChanged = _currentLanguage != language;
    final shouldConfirmStartup = confirmStartup && !_startupConfirmed;

    if (!languageChanged && !shouldConfirmStartup) {
      return;
    }

    _currentLanguage = language;
    await _preferences.setString(_languageKey, _currentLanguage.storageValue);

    if (confirmStartup) {
      await _preferences.setBool(_startupConfirmedKey, true);
      _startupConfirmed = true;
    }

    notifyListeners();
  }

  Future<void> confirmStartupLanguage() async {
    await updateLanguage(_currentLanguage, confirmStartup: true);
  }
}
