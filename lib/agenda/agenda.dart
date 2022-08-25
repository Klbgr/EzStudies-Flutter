import 'package:ezstudies/agenda/trash.dart';
import 'package:ezstudies/utils/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/templates.dart';
import '../utils/timestamp_utils.dart';
import 'add.dart';
import 'agenda_cell.dart';
import 'agenda_cell_data.dart';

class Agenda extends StatefulWidget {
  const Agenda({Key? key}) : super(key: key);

  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  bool initialized = false;
  List<AgendaCellData> list = [];
  final TextStyle menuStyle = const TextStyle(fontSize: 16);

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      initialized = true;
      load();
    }
    list.removeWhere((element) => element.trashed == 1);
    list.sort((a, b) => a.start.compareTo(b.start));

    OpenContainerTemplate trash = OpenContainerTemplate(
        Text(AppLocalizations.of(context)!.trash, style: menuStyle),
        const Trash(),
        () => load());

    Widget menu = MenuTemplate(<PopupMenuItem<String>>[
      PopupMenuItem<String>(value: "trash", child: trash),
      PopupMenuItem<String>(
          value: "reset", child: Text(AppLocalizations.of(context)!.reset)),
      PopupMenuItem<String>(
          value: "help", child: Text(AppLocalizations.of(context)!.help))
    ], (value) {
      switch (value) {
        case "trash":
          trash.getTrigger().call();
          break;
        case "reset":
          showDialog(
            context: context,
            builder: (context) => AlertDialogTemplate(
                AppLocalizations.of(context)!.reset, "reset?", [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel)),
              TextButton(
                  onPressed: () {
                    reset();
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.reset))
            ]),
          );
          break;
        case "help":
          showDialog(
            context: context,
            builder: (context) => AlertDialogTemplate(
                AppLocalizations.of(context)!.help, "help", [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.ok))
            ]),
          );
          break;
      }
    });

    OpenContainerTemplate add = OpenContainerTemplate(
        Row(
          children: [
            Container(
                margin: const EdgeInsets.only(right: 10),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                )),
            Text(
              AppLocalizations.of(context)!.add,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
        Add(),
        () => load());

    Widget content = Center(
        child: TextButton(
            onPressed: () => refresh(),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: const Icon(Icons.refresh, size: 16),
              ),
              Text(AppLocalizations.of(context)!.refresh)
            ])));
    if (list.isNotEmpty) {
      content = ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: list.length,
        itemBuilder: (context, index) {
          var data = list[index];
          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              remove(data);
            },
            background: Container(
                color: Colors.red,
                child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(Icons.delete),
                          Icon(Icons.delete)
                        ]))),
            child: AgendaCell(
                data,
                index == 0 || !isSameDay(data.start, list[index - 1].start),
                index == 0 || !isSameMonth(data.start, list[index - 1].start),
                () => load()),
          );
        },
      );
    }

    Widget child = Stack(
      children: [
        RefreshIndicator(onRefresh: () => refresh(), child: content),
        Container(
          alignment: Alignment.bottomRight,
          margin: const EdgeInsets.only(right: 20, bottom: 20),
          child: FloatingActionButton.extended(
            onPressed: () {
              add.getTrigger().call();
            },
            label: add,
          ),
        )
      ],
    );

    return Template(AppLocalizations.of(context)!.agenda, child, menu, false);
  }

  void load() {
    DatabaseHelper database = DatabaseHelper();
    database
        .open()
        .then((value) => database.get(DatabaseHelper.agenda).then((value) {
              setState(() {
                list = value;
              });
              database.close();
            }));
  }

  void remove(AgendaCellData data) {
    data.trashed = 1;
    DatabaseHelper database = DatabaseHelper();
    database.open().then((value) => database
        .insertOrReplace(DatabaseHelper.agenda, data)
        .then((value) => database.close()));
    setState(() => list.remove(data));
  }

  void reset() {
    DatabaseHelper database = DatabaseHelper();
    database.open().then((value) => database
        .reset()
        .then((value) => database.close().then((value) => load())));
  }

  Future<void> refresh() async {
    load();
  }
}
