import 'package:ezstudies/settings/color_dialog.dart';
import 'package:ezstudies/settings/theme_dialog.dart';
import 'package:ezstudies/utils/database_helper.dart';
import 'package:ezstudies/welcome/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/cipher.dart';
import '../utils/preferences.dart';
import '../utils/secret.dart';
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

  @override
  Widget build(BuildContext context) {
    String theme = "";
    switch (Preferences.sharedPreferences.getInt("theme") ?? 0) {
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
          tiles: <SettingsTile>[
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
            SettingsTile.switchTile(
                leading: const Icon(Icons.notifications),
                initialValue:
                    Preferences.sharedPreferences.getBool("notifications") ??
                        true,
                onToggle: (value) =>
                    (Preferences.sharedPreferences.getBool("notifications") ??
                            true)
                        ? Preferences.sharedPreferences
                            .setBool("notifications", false)
                            .then((value) => setState(() {}))
                        : Preferences.sharedPreferences
                            .setBool("notifications", true)
                            .then((value) => setState(() {})),
                title: Text(AppLocalizations.of(context)!.notifications,
                    style: font),
                description: Text("desc", style: GoogleFonts.openSans()))
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
                          Preferences.sharedPreferences.getString("name") ?? "",
                          Secret.cipherKey),
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
                  title: Text(AppLocalizations.of(context)!.report_bug_feddback,
                      style: font)),
              SettingsTile(
                  leading: const Icon(Icons.logo_dev),
                  title:
                      Text(AppLocalizations.of(context)!.made_by, style: font),
                  value: Text("Antoine Qiu (GitHub: @Klbgr)", style: font),
                  onPressed: (context) => launchUrl(
                      Uri.parse("https://github.com/Klbgr"),
                      mode: LaunchMode.externalApplication)),
              SettingsTile(
                  leading: const Icon(Icons.numbers),
                  title:
                      Text(AppLocalizations.of(context)!.version, style: font),
                  value: Text(Preferences.packageInfo.version, style: font)),
            ])
      ],
    );

    return Template(AppLocalizations.of(context)!.settings, child, back: false);
  }

  void reloadTheme() {
    Style.load().then((value) {
      setState(() => widget.reloadTheme());
    });
  }

  void disconnect() {
    Preferences.sharedPreferences.remove("name").then((_) =>
        Preferences.sharedPreferences.remove("password").then((value) {
          DatabaseHelper database = DatabaseHelper();
          database.open().then((value) => database.reset().then((value) =>
              database.close().then((value) => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Welcome())))));
        }));
  }
}
