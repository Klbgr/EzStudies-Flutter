import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences sharedPreferences;
  static late PackageInfo packageInfo;

  static Future<void> load() async {
    sharedPreferences = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();
  }
}
