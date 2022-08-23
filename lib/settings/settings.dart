import 'package:ezstudies/templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:settings_ui/settings_ui.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    Widget child = SettingsList(
      lightTheme: const SettingsThemeData(
          settingsListBackground: Colors.transparent,
          titleTextColor: Colors.green,
          leadingIconsColor: Colors.black),
      sections: [
        SettingsSection(
          title: Text('App'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: Icon(Icons.format_paint),
              title: Text('Theme'),
              value: Text('light'),
            )
          ],
        ),
        SettingsSection(title: Text("account"), tiles: <SettingsTile>[
          SettingsTile(
            title: Text("deco"),
            onPressed: (context) => disconnect(),
          )
        ])
      ],
    );
    return Template(AppLocalizations.of(context)!.settings, child, null, false);
  }

  void disconnect() {}
}
