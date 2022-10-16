import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences sharedPreferences;
  static late PackageInfo packageInfo;
  static const String notifications = "notifications";
  static const String helpAgenda = "help_agenda";
  static const String helpTrash = "help_trash";
  static const String helpSearchAgenda = "help_search_agenda";
  static const String name = "name";
  static const String password = "password";
  static const String notificationsHomeworks = "notifications_homeworks";
  static const String helpHomeworks = "help_homeworks";
  static const String helpSearch = "help_search";
  static const String accent = "accent";
  static const String useSystemAccent = "use_system_accent";
  static const String theme = "theme";

  static Future<void> load() async {
    sharedPreferences = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();
  }
}
