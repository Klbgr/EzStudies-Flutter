import 'dart:io';

import 'package:ezstudies/utils/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:system_theme/system_theme.dart';

class Style {
  static late int theme;
  static late Color primary;
  static late Color secondary;
  static late Color background;
  static late Color text;
  static late Color hint;
  static late Color ripple;

  static Future<void> load() async {
    MaterialColor color =
        Colors.primaries[Preferences.sharedPreferences.getInt("accent") ?? 5];
    if ((Preferences.sharedPreferences.getBool("use_system_accent") ?? true) &&
        (Platform.isAndroid || kIsWeb)) {
      color = generateMaterialColor(color: SystemTheme.accentColor.accent);
    }
    switch (Preferences.sharedPreferences.getInt("theme") ?? 0) {
      case 0:
        (SchedulerBinding.instance.window.platformBrightness ==
                Brightness.light)
            ? _setLightTheme(color)
            : _setDarkTheme(color);
        break;
      case 1:
        _setLightTheme(color);
        break;
      case 2:
        _setDarkTheme(color);
        break;
    }
  }

  static _setLightTheme(MaterialColor color) {
    theme = 0;
    primary = color;
    secondary = color.shade100;
    background = color.shade50;
    text = Colors.black;
    hint = Colors.grey;
    ripple = primary.withAlpha(50);
  }

  static _setDarkTheme(MaterialColor color) {
    theme = 1;
    primary = color.shade700;
    secondary = const Color(0xFF161616);
    background = const Color(0xFF121212);
    text = color.shade50;
    hint = Colors.grey;
    ripple = primary.withAlpha(50);
  }
}
