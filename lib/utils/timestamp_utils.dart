import 'dart:ui';

import 'package:ezstudies/main.dart';
import 'package:intl/intl.dart';
import 'package:universal_io/io.dart';
import 'package:week_of_year/date_week_extensions.dart';

String timestampToTime(int timestamp) {
  return DateFormat("HH:mm", getLocale())
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
}

String timestampToWeekDay(int timestamp) {
  String weekday = DateFormat("E", getLocale())
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  if (weekday.length <= 3) {
    return weekday;
  }
  return weekday.substring(0, 3);
}

String timestampToMonthYear(int timestamp) {
  String date = DateFormat("MMMM y", getLocale())
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  return date.substring(0, 1).toUpperCase() + date.substring(1);
}

String timestampToDayMonth(int timestamp) {
  return DateFormat("dd/MM", getLocale())
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
}

String timestampToDayMonthYear(int timestamp) {
  return DateFormat("dd/MM/y", getLocale())
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
}

int timestampToDayOfMonth(int timestamp) {
  return DateTime.fromMillisecondsSinceEpoch(timestamp).day;
}

int timestampToMonth(int timestamp) {
  return DateTime.fromMillisecondsSinceEpoch(timestamp).month;
}

int timestampToWeekOfYear(int timestamp) {
  return DateTime.fromMillisecondsSinceEpoch(timestamp).weekOfYear;
}

bool isSameDay(int timestamp1, int timestamp2) {
  return timestampToDayOfMonth(timestamp1) == timestampToDayOfMonth(timestamp2);
}

bool isSameMonth(int timestamp1, int timestamp2) {
  return timestampToMonth(timestamp1) == timestampToMonth(timestamp2);
}

bool isSameWeek(int timestamp1, int timestamp2) {
  return timestampToWeekOfYear(timestamp1) == timestampToWeekOfYear(timestamp2);
}

String getLocale() {
  String locale = Platform.localeName;
  if (!EzStudies.supportedLocales.contains(Locale(locale.split("_").first))) {
    bool found = false;
    for (Locale supportedLocale in PlatformDispatcher.instance.locales) {
      if (EzStudies.supportedLocales
          .contains(Locale(supportedLocale.languageCode))) {
        locale = supportedLocale.toString();
        found = true;
        break;
      }
    }
    if (!found) {
      locale = "en";
    }
  }

  return locale;
}
