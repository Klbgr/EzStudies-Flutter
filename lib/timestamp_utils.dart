import 'dart:io';

import 'package:intl/intl.dart';

String timestampToTime(int timestamp) {
  return DateFormat("HH:mm", getLocale())
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
}

String timestampToWeekDay(int timestamp) {
  return DateFormat("E", getLocale())
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp))
      .substring(0, 3);
}

String timestampToMonthYear(int timestamp) {
  String date = DateFormat("MMMM y", getLocale())
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  return date.substring(0, 1).toUpperCase() + date.substring(1);
}

int timestampToDayOfMonth(int timestamp) {
  return int.parse(DateFormat("d", getLocale())
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp)));
}

int timestampToMonth(int timestamp) {
  return int.parse(DateFormat("M", getLocale())
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp)));
}

bool isSameDay(int timestamp1, int timestamp2) {
  return timestampToDayOfMonth(timestamp1) == timestampToDayOfMonth(timestamp2);
}

bool isSameMonth(int timestamp1, int timestamp2) {
  return timestampToMonth(timestamp1) == timestampToMonth(timestamp2);
}

String getLocale() {
  return Platform.localeName;
}
