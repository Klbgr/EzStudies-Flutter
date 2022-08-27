import 'package:ezstudies/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Style {
  static late int theme;
  static late Color primary;
  static late Color secondary;
  static late Color background;
  static late Color text;
  static late Color hint;
  static late Color ripple;

  static Future<void> load() async {
    int index = Preferences.sharedPreferences.getInt("accent") ?? 5;
    switch (Preferences.sharedPreferences.getInt("theme") ?? 0) {
      case 0:
        Brightness brightness =
            SchedulerBinding.instance.window.platformBrightness;
        (brightness == Brightness.light)
            ? _setLightTheme(index)
            : _setDarkTheme(index);
        break;
      case 1:
        _setLightTheme(index);
        break;
      case 2:
        _setDarkTheme(index);
        break;
    }
  }

  static _setLightTheme(int index) {
    theme = 0;
    primary = Colors.primaries[index];
    secondary = Colors.primaries[index].shade100;
    background = Colors.primaries[index].shade50;
    text = Colors.black;
    hint = Colors.grey;
    ripple = primary.withAlpha(50);
  }

  static _setDarkTheme(int index) {
    theme = 1;
    primary = Colors.primaries[index].shade700;
    secondary = Colors.primaries[index].shade800;
    background = const Color(0xFF121212);
    text = Colors.primaries[index].shade50;
    hint = Colors.grey;
    ripple = primary.withAlpha(50);
  }
}
