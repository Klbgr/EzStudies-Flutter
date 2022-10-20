import 'package:ezstudies/utils/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:system_theme/system_theme.dart';
import 'package:universal_io/io.dart';

class Style {
  static late int theme;
  static late Color primary;
  static late Color secondary;
  static late Color background;
  static late Color text;
  static late Color hint;
  static late Color ripple;

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

  static MaterialColor _getColor(double ratio) {
    MaterialColor color = Colors.primaries[
        Preferences.sharedPreferences.getInt(Preferences.accent) ?? 5];
    if ((Preferences.sharedPreferences.getBool(Preferences.useSystemAccent) ??
            true) &&
        (kIsWeb || Platform.isAndroid)) {
      Color accent = SystemTheme.accentColor.accent;
      if (Platform.isAndroid) {
        accent = _editColor(accent, ratio);
      }
      color = generateMaterialColor(color: accent);
    }
    return color;
  }

  static Color _editColor(Color color, double ratio) {
    color = color.withRed((color.red * ratio).toInt());
    color = color.withGreen((color.green * ratio).toInt());
    color = color.withBlue((color.blue * ratio).toInt());
    return color;
  }

  static _setLightTheme() {
    MaterialColor color = _getColor(0.8);
    theme = 0;
    primary = color;
    secondary = color.shade100;
    background = color.shade50;
    text = _editColor(color, 0.2);
    hint = Colors.grey;
    ripple = primary.withAlpha(50);
  }

  static _setDarkTheme() {
    MaterialColor color = _getColor(0.9);
    theme = 1;
    primary = color.shade700;
    secondary = _editColor(color, 0.15);
    background = _editColor(color, 0.1);
    text = color.shade50;
    hint = Colors.grey;
    ripple = primary.withAlpha(50);
  }
}
