import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:universal_io/io.dart';

import '../utils/preferences.dart';

class ColorDialog extends StatefulWidget {
  const ColorDialog({required this.onClosed, super.key});

  final Function onClosed;

  @override
  State<ColorDialog> createState() => _ColorDialogState();
}

class _ColorDialogState extends State<ColorDialog> {
  final int itemsPerLine = 4;
  int color = Preferences.sharedPreferences.getInt(Preferences.accent) ??
      Colors.primaries[5].value;
  bool useSystemAccent =
      Preferences.sharedPreferences.getBool(Preferences.useSystemAccent) ??
          true;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && !Platform.isAndroid) {
      useSystemAccent = false;
    }

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.accent_color),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        if (!useSystemAccent)
          ColorPicker(
            hexInputBar: true,
            labelTypes: const [],
            pickerColor: Color(color).withAlpha(255),
            onColorChanged: (Color newColor) =>
                color = newColor.withAlpha(255).value,
            enableAlpha: false,
          ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          enabled: kIsWeb || Platform.isAndroid,
          value: useSystemAccent,
          onChanged: (value) =>
              setState(() => useSystemAccent = !useSystemAccent),
          title: Text(
            AppLocalizations.of(context)!.use_system_accent_color,
          ),
        )
      ]),
      scrollable: true,
      actions: <Widget>[
        TextButton(
            child: Text(
              AppLocalizations.of(context)!.ok,
            ),
            onPressed: () => Preferences.sharedPreferences
                .setInt(Preferences.accent, color)
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
