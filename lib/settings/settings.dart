import 'package:ezstudies/settings/color_dialog.dart';
import 'package:ezstudies/settings/theme_dialog.dart';
import 'package:ezstudies/utils/database_helper.dart';
import 'package:ezstudies/welcome/welcome.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/env.dart';
import '../utils/cipher.dart';
import '../utils/notifications.dart';
import '../utils/preferences.dart';
import '../utils/style.dart';
import '../utils/templates.dart';

class Settings extends StatefulWidget {
  const Settings({required this.reloadTheme, Key? key}) : super(key: key);
  final Function reloadTheme;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextStyle font = GoogleFonts.openSans();
  int count = 0;
  DateTime? date;

  @override
  Widget build(BuildContext context) {
    String theme = "";
    switch (Preferences.sharedPreferences.getInt(Preferences.theme) ?? 0) {
      case 0:
        theme = AppLocalizations.of(context)!.automatic;
        break;
      case 1:
        theme = AppLocalizations.of(context)!.light;
        break;
      case 2:
        theme = AppLocalizations.of(context)!.dark;
        break;
    }

    Widget child = SettingsList(
      applicationType: ApplicationType.material,
      platform: DevicePlatform.android,
      lightTheme: SettingsThemeData(
          settingsListBackground: Colors.transparent,
          titleTextColor: Style.primary,
          leadingIconsColor: Style.text,
          tileDescriptionTextColor: Style.text,
          settingsTileTextColor: Style.text,
          tileHighlightColor: Style.ripple),
      sections: [
        SettingsSection(
          title: Text(AppLocalizations.of(context)!.general, style: font),
          tiles: [
            SettingsTile(
              leading: const Icon(Icons.format_paint),
              title: Text(AppLocalizations.of(context)!.theme, style: font),
              value: Text(theme, style: GoogleFonts.openSans()),
              onPressed: (context) => showDialog(
                  context: context,
                  builder: (context) =>
                      ThemeDialog(onClosed: () => reloadTheme())),
            ),
            SettingsTile(
                leading: const Icon(Icons.color_lens),
                title: Text(AppLocalizations.of(context)!.accent_color,
                    style: font),
                value: Icon(Icons.circle, color: Style.primary),
                onPressed: (context) => showDialog(
                    context: context,
                    builder: (context) =>
                        ColorDialog(onClosed: () => reloadTheme()))),
            if (!kIsWeb)
              SettingsTile.switchTile(
                  leading: const Icon(Icons.notifications),
                  initialValue: Preferences.sharedPreferences
                          .getBool(Preferences.notifications) ??
                      true,
                  onToggle: (value) {
                    Preferences.sharedPreferences
                        .setBool(Preferences.notifications, value)
                        .then((value) => setState(() {}));
                    if (!value) {
                      Notifications.cancelNotificationsAgenda();
                    }
                  },
                  title: Text(
                      AppLocalizations.of(context)!.notifications_agenda,
                      style: font),
                  description: Text(
                      AppLocalizations.of(context)!.notifications_agenda_desc,
                      style: GoogleFonts.openSans())),
            if (!kIsWeb)
              SettingsTile.switchTile(
                  leading: const Icon(Icons.notifications),
                  initialValue: Preferences.sharedPreferences
                          .getBool(Preferences.notificationsHomeworks) ??
                      true,
                  onToggle: (value) {
                    Preferences.sharedPreferences
                        .setBool(Preferences.notificationsHomeworks, value)
                        .then((value) => setState(() {}));
                    if (!value) {
                      Notifications.cancelNotificationsHomeworks();
                    }
                  },
                  title: Text(
                      AppLocalizations.of(context)!.notifications_homeworks,
                      style: font),
                  description: Text(
                      AppLocalizations.of(context)!
                          .notifications_homeworks_desc,
                      style: GoogleFonts.openSans()))
          ],
        ),
        SettingsSection(
            title: Text(AppLocalizations.of(context)!.account, style: font),
            tiles: <SettingsTile>[
              SettingsTile(
                  leading: const Icon(Icons.person),
                  title:
                      Text(AppLocalizations.of(context)!.account, style: font),
                  value: Text(
                      decrypt(
                          Preferences.sharedPreferences
                                  .getString(Preferences.name) ??
                              "",
                          Secret.cipher_key),
                      style: font)),
              SettingsTile(
                leading: const Icon(Icons.logout),
                title: Text(AppLocalizations.of(context)!.logout, style: font),
                onPressed: (context) => disconnect(),
              )
            ]),
        SettingsSection(
            title: Text(AppLocalizations.of(context)!.about, style: font),
            tiles: [
              SettingsTile(
                  leading: const Icon(Icons.bug_report),
                  title: Text(AppLocalizations.of(context)!.report_bug_feedback,
                      style: font),
                  onPressed: (context) => launchUrl(
                      Uri.parse(
                          "https://docs.google.com/forms/d/e/1FAIpQLSeEDjP8qGxxHHmIadZYaxhaDkZw1_4rqaNBbegskcjbTUlxiQ/viewform?usp=pp_url"),
                      mode: LaunchMode.externalApplication)),
              SettingsTile(
                  leading: const Icon(Icons.logo_dev),
                  title:
                      Text(AppLocalizations.of(context)!.made_by, style: font),
                  value: Text("Antoine Qiu (https://github.com/Klbgr)",
                      style: font),
                  onPressed: (context) => launchUrl(
                      Uri.parse("https://github.com/Klbgr"),
                      mode: LaunchMode.externalApplication)),
              SettingsTile(
                  leading: const Icon(Icons.code),
                  title: Text(AppLocalizations.of(context)!.source_code,
                      style: font),
                  value: Text("https://github.com/Klbgr/EzStudies-Flutter",
                      style: font),
                  onPressed: (context) => launchUrl(
                      Uri.parse("https://github.com/Klbgr/EzStudies-Flutter"),
                      mode: LaunchMode.externalApplication)),
              SettingsTile(
                  leading: const Icon(Icons.numbers),
                  title:
                      Text(AppLocalizations.of(context)!.version, style: font),
                  value: Text(Preferences.packageInfo.version, style: font),
                  onPressed: (context) {
                    DateTime now = DateTime.now();
                    if (date == null ||
                        now.millisecondsSinceEpoch -
                                date!.millisecondsSinceEpoch >
                            3 * 1000) {
                      date = DateTime.now();
                      count = 1;
                    } else if (count == 4) {
                      date = null;
                      count = 0;
                      launchUrl(Uri.parse("https://youtu.be/a3Z7zEc7AXQ"),
                          mode: LaunchMode.externalApplication);
                    } else {
                      count++;
                    }
                  }),
            ])
      ],
    );

    return Template(
        title: AppLocalizations.of(context)!.settings,
        back: false,
        child: child);
  }

  Future<void> reloadTheme() async {
    await Style.load();
    setState(() => widget.reloadTheme());
  }

  void disconnect() {
    if (kIsWeb) {
      Preferences.sharedPreferences.clear().then((value) =>
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const Welcome())));
    } else {
      Preferences.sharedPreferences.clear().then((value) {
        DatabaseHelper database = DatabaseHelper();
        database.open().then((_) => database.deleteAll().then((_) => database
            .close()
            .then((_) => Notifications.cancelAllNotifications().then((_) =>
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Welcome()))))));
      });
    }
  }
}
