import 'package:ezstudies/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/templates.dart';
import '../utils/timestamp_utils.dart';
import 'agenda_cell.dart';
import 'agenda_cell_data.dart';

class Trash extends StatefulWidget {
  const Trash({Key? key}) : super(key: key);

  @override
  State<Trash> createState() => _TrashState();
}

class _TrashState extends State<Trash> {
  bool initialized = false;
  List<AgendaCellData> list = [];

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      initialized = true;
      DatabaseHelper database = DatabaseHelper();
      database
          .open()
          .then((value) => database.get(DatabaseHelper.agenda).then((value) {
                setState(() {
                  list = value;
                  list.removeWhere((element) => element.trashed == 0);
                  list.sort((a, b) => a.start.compareTo(b.start));
                });
                database.close();
              }));
    }

    Widget child = Center(
      child: Text(AppLocalizations.of(context)!.nothing_to_show),
    );
    if (list.isNotEmpty) {
      child = ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: list.length,
        itemBuilder: (context, index) {
          var data = list[index];
          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              restore(data);
            },
            background: Container(
                color: Colors.green,
                child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(Icons.restore_from_trash),
                          Icon(Icons.restore_from_trash)
                        ]))),
            child: AgendaCell(
                data,
                index == 0 || !isSameDay(data.start, list[index - 1].start),
                index == 0 || !isSameMonth(data.start, list[index - 1].start),
                () {}),
          );
        },
      );
    }

    Widget menu = MenuTemplate(<PopupMenuItem<String>>[
      PopupMenuItem(
          value: "help", child: Text(AppLocalizations.of(context)!.help))
    ], (value) {
      switch (value) {
        case "help":
          showDialog(
              context: context,
              builder: (context) => AlertDialogTemplate(
                      AppLocalizations.of(context)!.help, "help?", [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.ok))
                  ]));
          break;
      }
    });

    return Template(AppLocalizations.of(context)!.trash, child, menu, true);
  }

  void restore(AgendaCellData data) {
    data.trashed = 0;
    DatabaseHelper database = DatabaseHelper();
    database.open().then((value) => database
        .insertOrReplace(DatabaseHelper.agenda, data)
        .then((value) => database.close()));
    setState(() => list.remove(data));
  }
}
