import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:universal_io/io.dart';

import '../utils/preferences.dart';
import '../utils/style.dart';

class ColorDialog extends StatefulWidget {
  const ColorDialog({required this.onClosed, super.key});
  final Function onClosed;

  @override
  State<ColorDialog> createState() => _ColorDialogState();
}

class _ColorDialogState extends State<ColorDialog> {
  final int itemsPerLine = 4;
  int selectedIndex =
      Preferences.sharedPreferences.getInt(Preferences.accent) ?? 5;
  bool useSystemAccent =
      Preferences.sharedPreferences.getBool(Preferences.useSystemAccent) ??
          true;

  @override
  Widget build(BuildContext context) {
    Column column = Column(
        mainAxisSize: MainAxisSize.min, children: List.empty(growable: true));
    Row row = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.empty(growable: true));
    for (int i = 0; i < Colors.primaries.length; i++) {
      if (i != 0 && i % itemsPerLine == 0) {
        column.children.add(row);
        row = Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.empty(growable: true));
      } else if (i == Colors.primaries.length - 1) {
        column.children.add(row);
      }
      row.children.add(Stack(
        children: [
          Icon(
            Icons.circle,
            color: (Style.theme == 0)
                ? Colors.primaries[i].shade600
                : Colors.primaries[i].shade700,
            size: 64,
          ),
          GestureDetector(
              child: Icon(Icons.check_rounded,
                  size: 64,
                  color: (i == selectedIndex && !useSystemAccent)
                      ? Style.background
                      : Colors.transparent),
              onTap: () => setState(() {
                    selectedIndex = i;
                    useSystemAccent = false;
                  }))
        ],
      ));
    }

    if (kIsWeb || Platform.isAndroid) {
      column.children.add(CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          value: useSystemAccent,
          onChanged: (value) =>
              setState(() => useSystemAccent = !useSystemAccent),
          title: Text(AppLocalizations.of(context)!.use_system_accent_color,
              style: TextStyle(color: Style.text)),
          checkColor: Style.background));
    } else {
      useSystemAccent = false;
    }

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.accent_color),
      content: column,
      scrollable: true,
      actions: <Widget>[
        TextButton(
            child: Text(AppLocalizations.of(context)!.ok,
                style: TextStyle(color: Style.primary)),
            onPressed: () => Preferences.sharedPreferences
                .setInt(Preferences.accent, selectedIndex)
                .then((value) => Preferences.sharedPreferences
                        .setBool(Preferences.useSystemAccent, useSystemAccent)
                        .then((value) {
                      Navigator.pop(context);
                      widget.onClosed();
                    }))),
      ],
    );
  }
}
