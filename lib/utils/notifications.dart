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
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    initializeTimeZones();
    await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"),
            iOS: IOSInitializationSettings()));
  }

  static Future<void> _scheduleNotification(int id, BuildContext context,
      String title, String body, int timestamp) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      TZDateTime.fromMillisecondsSinceEpoch(local, timestamp),
      NotificationDetails(
        android: AndroidNotificationDetails(
            "reminder", AppLocalizations.of(context)!.reminder,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority),
        iOS: const IOSNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  static Future<void> scheduleNotifications(BuildContext context) async {
    DatabaseHelper database = DatabaseHelper();
    database
        .open()
        .then((value) => database.get(DatabaseHelper.agenda).then((value) {
              for (int i = 0; i < value.length; i++) {
                if (value[i].trashed == 0 &&
                    value[i].start + 15 * 60 * 1000 >=
                        DateTime.now().millisecondsSinceEpoch) {
                  _scheduleNotification(
                      i,
                      context,
                      AppLocalizations.of(context)!.reminder,
                      value[i].description,
                      value[i].start - 15 * 60 * 1000);
                }
              }
              database.close();
            }));
  }

  static Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
