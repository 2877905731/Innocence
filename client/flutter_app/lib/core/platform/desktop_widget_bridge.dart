import 'package:flutter/services.dart';

import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/features/settings/domain/models/appearance_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/widget_setting.dart';

class DesktopWidgetBridge {
  DesktopWidgetBridge._();

  static const MethodChannel _channel =
      MethodChannel('innocence/desktop_widget');
  static bool _nativeHandlerReady = false;
  static void Function(String mode)? _windowModeListener;

  static void setWindowModeListener(void Function(String mode)? listener) {
    if (AppConfig.deviceType != 'windows') {
      return;
    }
    _ensureNativeHandler();
    _windowModeListener = listener;
  }

  static void _ensureNativeHandler() {
    if (_nativeHandlerReady) {
      return;
    }
    _nativeHandlerReady = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'windowModeChanged') {
        return;
      }
      final arguments = call.arguments;
      if (arguments is Map) {
        final mode = arguments['mode'];
        if (mode is String && mode.isNotEmpty) {
          _windowModeListener?.call(mode);
        }
      }
    });
  }

  static Future<void> applySettings({
    required WidgetSetting widgetSetting,
    required AppearanceSetting appearanceSetting,
  }) async {
    if (AppConfig.deviceType != 'windows') {
      return;
    }

    try {
      await _channel.invokeMethod<void>(
        'setAlwaysOnTop',
        <String, bool>{
          'enabled': widgetSetting.alwaysOnTop,
        },
      );
      await _channel.invokeMethod<void>(
        'setAutoStart',
        <String, bool>{
          'enabled': widgetSetting.autoStart,
        },
      );
      await _channel.invokeMethod<void>(
        'setDesktopEffect',
        <String, String>{
          'effect': appearanceSetting.desktopEffect,
        },
      );
    } on MissingPluginException {
      // Ignore when the current platform does not expose the desktop bridge.
    } on PlatformException {
      // Keep the server-side setting even if the local shell cannot apply it.
    }
  }

  static Future<void> updateWindowHeight(double logicalHeight) async {
    if (AppConfig.deviceType != 'windows') {
      return;
    }

    try {
      await _channel.invokeMethod<void>(
        'setWindowHeight',
        <String, double>{
          'height': logicalHeight,
        },
      );
    } on MissingPluginException {
      // Ignore when the current platform does not expose the desktop bridge.
    } on PlatformException {
      // Keep the widget usable even if the native shell resize fails.
    }
  }

  static Future<void> setWindowMode(String mode) async {
    if (AppConfig.deviceType != 'windows') {
      return;
    }

    try {
      await _channel.invokeMethod<void>(
        'setWindowMode',
        <String, String>{
          'mode': mode,
        },
      );
    } on MissingPluginException {
      // Ignore when the current platform does not expose the desktop bridge.
    } on PlatformException {
      // Keep the app usable even if the native shell cannot resize.
    }
  }

  static Future<void> startWindowDrag() async {
    if (AppConfig.deviceType != 'windows') {
      return;
    }

    try {
      await _channel.invokeMethod<void>('startWindowDrag');
    } on MissingPluginException {
      // Ignore when the current platform does not expose the desktop bridge.
    } on PlatformException {
      // Keep the widget usable even if the native shell drag fails.
    }
  }

  static Future<void> resetWindowPosition() async {
    if (AppConfig.deviceType != 'windows') {
      return;
    }

    try {
      await _channel.invokeMethod<void>('resetWindowPosition');
    } on MissingPluginException {
      // Ignore when the current platform does not expose the desktop bridge.
    } on PlatformException {
      // Keep the widget usable even if the native shell reset fails.
    }
  }

  static Future<void> closeWindow() async {
    if (AppConfig.deviceType != 'windows') {
      return;
    }

    try {
      await _channel.invokeMethod<void>('closeWindow');
    } on MissingPluginException {
      // Ignore when the current platform does not expose the desktop bridge.
    } on PlatformException {
      // Keep the app usable even if the native shell close action fails.
    }
  }

  static Future<void> hideWindow() async {
    if (AppConfig.deviceType != 'windows') {
      return;
    }

    try {
      await _channel.invokeMethod<void>('hideWindow');
    } on MissingPluginException {
      // Ignore when the current platform does not expose the desktop bridge.
    } on PlatformException {
      // Keep the app usable even if the native shell hide action fails.
    }
  }

  static Future<void> showMiniWindow() async {
    await setWindowMode('mini');
  }

  static Future<void> showPageWindow() async {
    await setWindowMode('page');
  }

  static Future<void> showWidgetWindow() async {
    await setWindowMode('widget');
  }
}
