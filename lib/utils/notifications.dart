import 'package:ezstudies/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

class Notifications {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    if (!await _checkPermission()) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    }

    initializeTimeZones();
    await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
            android: AndroidInitializationSettings(
                "@drawable/ic_launcher_foreground"),
            iOS: DarwinInitializationSettings()));
  }

  static Future<bool> _checkPermission() async {
    return (await flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.areNotificationsEnabled() ??
            false) &&
        (await flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.canScheduleExactNotifications() ??
            false);
  }

  static Future<void> _scheduleNotification(int id, BuildContext context,
      String title, String body, int timestamp) async {
    if (!await _checkPermission()) {
      return;
    }
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      TZDateTime.fromMillisecondsSinceEpoch(local, timestamp),
      NotificationDetails(
        android: AndroidNotificationDetails(
            "reminder", AppLocalizations.of(context)!.reminders,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  static Future<void> scheduleNotificationsAgenda(BuildContext context) async {
    DatabaseHelper database = DatabaseHelper();
    database.open().then((_) => database
        .getAgenda(DatabaseHelper.agenda)
        .then((value) => database.close().then((_) {
              for (int i = 0; i < value.length; i++) {
                if (value[i].trashed == 0 &&
                    value[i].start - 15 * 60 * 1000 >=
                        DateTime.now().millisecondsSinceEpoch) {
                  _scheduleNotification(
                      i,
                      context,
                      AppLocalizations.of(context)!.notifications_agenda_title,
                      value[i].description,
                      value[i].start - 15 * 60 * 1000);
                }
              }
            })));
  }

  static Future<void> scheduleNotificationsHomeworks(
      BuildContext context) async {
    DatabaseHelper database = DatabaseHelper();
    database.open().then((_) =>
        database.getHomeworks().then((value) => database.close().then((_) {
              for (int i = 0; i < value.length; i++) {
                if (value[i].done == 0 &&
                    value[i].date - 24 * 60 * 60 * 1000 >=
                        DateTime.now().millisecondsSinceEpoch) {
                  _scheduleNotification(
                      i + 1000,
                      context,
                      AppLocalizations.of(context)!
                          .notifications_homeworks_title,
                      value[i].description,
                      value[i].date - 24 * 60 * 60 * 1000);
                }
              }
            })));
  }

  static Future<void> cancelNotificationsAgenda() async {
    for (PendingNotificationRequest p in await flutterLocalNotificationsPlugin
        .pendingNotificationRequests()) {
      if (p.id < 1000) {
        await flutterLocalNotificationsPlugin.cancel(p.id);
      }
    }
  }

  static Future<void> cancelNotificationsHomeworks() async {
    for (PendingNotificationRequest p in await flutterLocalNotificationsPlugin
        .pendingNotificationRequests()) {
      if (p.id >= 1000) {
        await flutterLocalNotificationsPlugin.cancel(p.id);
      }
    }
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
