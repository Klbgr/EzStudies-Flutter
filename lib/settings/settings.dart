import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:settings_ui/settings_ui.dart';

import '../utils/templates.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    Widget child = SettingsList(
      applicationType: ApplicationType.material,
      lightTheme: const SettingsThemeData(
          settingsListBackground: Colors.transparent,
          titleTextColor: Colors.green,
          leadingIconsColor: Colors.black),
      sections: [
        SettingsSection(
          title: Text(AppLocalizations.of(context)!.general),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.format_paint),
              title: const Text('Theme'),
              value: const Text('light'),
            ),
            SettingsTile(
                leading: const Icon(Icons.color_lens),
                title: const Text("accent color")),
            SettingsTile.switchTile(
                leading: const Icon(Icons.notifications),
                initialValue: true,
                onToggle: (value) {},
                title: const Text("notif"))
          ],
        ),
        SettingsSection(
            title: Text(AppLocalizations.of(context)!.account),
            tiles: <SettingsTile>[
              SettingsTile(
                  leading: const Icon(Icons.person),
                  title: const Text("account"),
                  value: const Text("e-xxx")),
              SettingsTile(
                leading: const Icon(Icons.logout),
                title: const Text("deco"),
                onPressed: (context) => disconnect(),
              )
            ]),
        SettingsSection(
            title: Text(AppLocalizations.of(context)!.about),
            tiles: [
              SettingsTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text("report bug/feedback")),
              SettingsTile(
                  leading: const Icon(Icons.logo_dev),
                  title: const Text("dev by"),
                  value: const Text("Klbgr")),
              SettingsTile(
                  leading: const Icon(Icons.numbers),
                  title: const Text("version"),
                  value: const Text("1"))
            ])
      ],
    );

    return Template(AppLocalizations.of(context)!.settings, child, null, false);
  }

  void disconnect() {}
}
