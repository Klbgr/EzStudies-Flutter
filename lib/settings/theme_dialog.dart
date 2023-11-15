import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/preferences.dart';
import '../utils/style.dart';

class ThemeDialog extends StatefulWidget {
  const ThemeDialog({required this.onClosed, super.key});
  final Function onClosed;

  @override
  State<ThemeDialog> createState() => _ThemeDialogState();
}

class _ThemeDialogState extends State<ThemeDialog> {
  int selectedIndex =
      Preferences.sharedPreferences.getInt(Preferences.theme) ?? 0;

  @override
  Widget build(BuildContext context) {
    List<String> names = [
      AppLocalizations.of(context)!.automatic,
      AppLocalizations.of(context)!.light,
      AppLocalizations.of(context)!.dark
    ];

    Column column = Column(mainAxisSize: MainAxisSize.min, children: [
      for (int i = 0; i < 3; i++)
        InkWell(
            onTap: () => setState(() => selectedIndex = i),
            child: ListTile(
                title: Text(names[i]),
                leading: Radio<int>(
                    activeColor: Style.primary,
                    value: i,
                    groupValue: selectedIndex,
                    onChanged: (value) =>
                        setState(() => selectedIndex = value!))))
    ]);

    return AlertDialog(
      backgroundColor: Style.background,
      title: Text(AppLocalizations.of(context)!.theme),
      content: column,
      scrollable: true,
      actions: <Widget>[
        TextButton(
            child: Text(AppLocalizations.of(context)!.ok,
                style: TextStyle(color: Style.primary)),
            onPressed: () => Preferences.sharedPreferences
                    .setInt(Preferences.theme, selectedIndex)
                    .then((value) {
                  Navigator.pop(context);
                  widget.onClosed();
                })),
      ],
    );
  }
}
