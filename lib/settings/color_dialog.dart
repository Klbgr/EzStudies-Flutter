import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/preferences.dart';
import '../utils/style.dart';

class ColorDialog extends StatefulWidget {
  const ColorDialog({required this.onClosed, Key? key}) : super(key: key);
  final Function onClosed;

  @override
  State<ColorDialog> createState() => _ColorDialogState();
}

class _ColorDialogState extends State<ColorDialog> {
  final int itemsPerLine = 4;
  int selectedIndex = Preferences.sharedPreferences.getInt("accent") ?? 5;

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