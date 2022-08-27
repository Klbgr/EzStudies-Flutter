import 'package:ezstudies/utils/database_helper.dart';
import 'package:ezstudies/welcome/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
          title: Text(AppLocalizations.of(context)!.general),
          tiles: <SettingsTile>[
            SettingsTile(
              leading: const Icon(Icons.format_paint),
              title: Text(AppLocalizations.of(context)!.theme),
              value: Text(theme),
              onPressed: (context) => showDialog(
                  context: context,
                  builder: (context) =>
                      _ThemeChoice(onClosed: () => reloadTheme())),
            ),
            SettingsTile(
                leading: const Icon(Icons.color_lens),
                title: Text(AppLocalizations.of(context)!.accent_color),
                value: Icon(Icons.circle,
                    color: (Style.theme == 0)
                        ? Colors.primaries[
                            Preferences.sharedPreferences.getInt("accent") ?? 0]
                        : Colors
                            .primaries[Preferences.sharedPreferences
                                    .getInt("accent") ??
                                0]
                            .shade700),
                onPressed: (context) => showDialog(
                    context: context,
                    builder: (context) =>
                        _ColorPalette(onClosed: () => reloadTheme()))),
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
                title: Text(AppLocalizations.of(context)!.notifications))
          ],
        ),
        SettingsSection(
            title: Text(AppLocalizations.of(context)!.account),
            tiles: <SettingsTile>[
              SettingsTile(
                  leading: const Icon(Icons.person),
                  title: Text(AppLocalizations.of(context)!.account),
                  value: Text(decrypt(
                      Preferences.sharedPreferences.getString("name") ?? "",
                      Secret.cipherKey))),
              SettingsTile(
                leading: const Icon(Icons.logout),
                title: Text(AppLocalizations.of(context)!.logout),
                onPressed: (context) => disconnect(),
              )
            ]),
        SettingsSection(
            title: Text(AppLocalizations.of(context)!.about),
            tiles: [
              SettingsTile(
                  leading: const Icon(Icons.bug_report),
                  title:
                      Text(AppLocalizations.of(context)!.report_bug_feddback)),
              SettingsTile(
                  leading: const Icon(Icons.logo_dev),
                  title: Text(AppLocalizations.of(context)!.made_by),
                  value: const Text("Antoine Qiu (GitHub: @Klbgr)"),
                  onPressed: (context) => launchUrl(
                      Uri.parse("https://github.com/Klbgr"),
                      mode: LaunchMode.externalApplication)),
              SettingsTile(
                  leading: const Icon(Icons.numbers),
                  title: Text(AppLocalizations.of(context)!.version),
                  value: Text(Preferences.packageInfo.version)),
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

class _ColorPalette extends StatefulWidget {
  const _ColorPalette({required this.onClosed, Key? key}) : super(key: key);
  final Function onClosed;

  @override
  State<_ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<_ColorPalette> {
  final int itemsPerLine = 4;
  int selectedIndex = Preferences.sharedPreferences.getInt("accent") ?? 0;

  @override
  Widget build(BuildContext context) {
    Column column = Column(mainAxisSize: MainAxisSize.min, children: []);
    Row row =
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: []);
    for (int i = 0; i < Colors.primaries.length; i++) {
      if (i != 0 && i % itemsPerLine == 0) {
        column.children.add(row);
        row =
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: []);
      } else if (i == Colors.primaries.length - 1) {
        column.children.add(row);
      }
      row.children.add(Stack(
        children: [
          Icon(
            Icons.circle,
            color: (Style.theme == 0)
                ? Colors.primaries[i]
                : Colors.primaries[i].shade700,
            size: 64,
          ),
          GestureDetector(
              child: Icon(Icons.check_rounded,
                  size: 64,
                  color: (i == selectedIndex)
                      ? Style.background
                      : Colors.transparent),
              onTap: () => setState(() => selectedIndex = i))
        ],
      ));
    }
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      backgroundColor: Style.background,
      title: Text(AppLocalizations.of(context)!.accent_color,
          style: TextStyle(color: Style.text)),
      content: column,
      actions: <Widget>[
        TextButton(
            child: Text(AppLocalizations.of(context)!.ok,
                style: TextStyle(color: Style.primary)),
            onPressed: () => Preferences.sharedPreferences
                    .setInt("accent", selectedIndex)
                    .then((value) {
                  Navigator.pop(context);
                  widget.onClosed();
                })),
      ],
    );
  }
}

class _ThemeChoice extends StatefulWidget {
  const _ThemeChoice({required this.onClosed, Key? key}) : super(key: key);
  final Function onClosed;

  @override
  State<_ThemeChoice> createState() => _ThemeChoiceState();
}

class _ThemeChoiceState extends State<_ThemeChoice> {
  int selectedIndex = Preferences.sharedPreferences.getInt("theme") ?? 0;

  @override
  Widget build(BuildContext context) {
    Column column = Column(mainAxisSize: MainAxisSize.min, children: []);
    List<String> names = [
      AppLocalizations.of(context)!.automatic,
      AppLocalizations.of(context)!.light,
      AppLocalizations.of(context)!.dark
    ];
    for (int i = 0; i < 3; i++) {
      column.children.add(ListTile(
          title: GestureDetector(
              child: Text(names[i]),
              onTap: () => setState(() => selectedIndex = i)),
          textColor: Style.text,
          leading: Radio<int>(
              activeColor: Style.primary,
              value: i,
              groupValue: selectedIndex,
              onChanged: (value) => setState(() => selectedIndex = value!))));
    }
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      backgroundColor: Style.background,
      title: Text(AppLocalizations.of(context)!.theme,
          style: TextStyle(color: Style.text)),
      content: column,
      actions: <Widget>[
        TextButton(
            child: Text(AppLocalizations.of(context)!.ok,
                style: TextStyle(color: Style.primary)),
            onPressed: () => Preferences.sharedPreferences
                    .setInt("theme", selectedIndex)
                    .then((value) {
                  Navigator.pop(context);
                  widget.onClosed();
                })),
      ],
    );
  }
}
