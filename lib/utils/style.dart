import 'package:ezstudies/utils/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:system_theme/system_theme.dart';
import 'package:universal_io/io.dart';

class Style {
  static late int theme;
  static late Color primary;

  static Future<void> load() async {
    switch (Preferences.sharedPreferences.getInt(Preferences.theme) ?? 0) {
      case 0:
        (SchedulerBinding.instance.window.platformBrightness ==
                Brightness.light)
            ? _setLightTheme()
            : _setDarkTheme();
        break;
      case 1:
        _setLightTheme();
        break;
      case 2:
        _setDarkTheme();
        break;
    }
  }

  static Color _getColor(double ratio) {
    Color color = Colors.primaries[
        Preferences.sharedPreferences.getInt(Preferences.accent) ?? 5];
    if ((Preferences.sharedPreferences.getBool(Preferences.useSystemAccent) ??
            true) &&
        (kIsWeb || Platform.isAndroid)) {
      Color accent = SystemTheme.accentColor.accent;
      color = accent;
    }
    return color;
  }

  static _setLightTheme() {
    theme = 0;
    primary = _getColor(1);
  }

  static _setDarkTheme() {
    theme = 1;
    primary = _getColor(1);
  }
}
