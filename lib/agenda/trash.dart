import 'package:ezstudies/database_helper.dart';
import 'package:ezstudies/templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../timestamp_utils.dart';
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
            child: _TrashCell(
                data,
                index == 0 || !isSameDay(data.start, list[index - 1].start),
                index == 0 || !isSameMonth(data.start, list[index - 1].start)),
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

class _TrashCell extends StatelessWidget {
  const _TrashCell(this.data, this.firstOfDay, this.firstOfMonth, {Key? key})
      : super(key: key);
  final bool firstOfDay;
  final bool firstOfMonth;
  final AgendaCellData data;

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(getLocale(), null);

    String start = timestampToTime(data.start);
    String end = timestampToTime(data.end);
    String description = data.description;
    if (description != "") {
      description = "($description)";
    }

    List<Text> date = <Text>[];
    if (firstOfDay) {
      date = [
        Text(timestampToWeekDay(data.start)),
        Text(timestampToDayOfMonth(data.start).toString(),
            style: const TextStyle(fontSize: 20))
      ];
    }
    List<Widget> children = [
      Text(
        data.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      )
    ];

    if (data.added == 0 && data.edited == 1) {
      children.add(const Icon(Icons.edit, size: 16));
    } else if (data.added == 1) {
      children.add(const Icon(Icons.add, size: 16));
    }

    Widget child = Row(children: [
      Container(
        alignment: Alignment.center,
        width: 30,
        child: Column(children: date),
      ),
      Expanded(
          child: Container(
              margin: const EdgeInsets.only(left: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: data.getColor(),
                  borderRadius: const BorderRadius.all(Radius.circular(16))),
              child: Column(children: [
                Container(
                    margin: const EdgeInsets.only(bottom: 2.5),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: children)),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "$start - $end $description",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ])))
    ]);

    if (firstOfMonth) {
      child = Column(children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(left: 50, top: 15, bottom: 10),
          child: Text(
            timestampToMonthYear(data.start),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        child,
      ]);
    }

    double margin = 0;
    if (firstOfMonth) {
      margin = 5;
    } else if (firstOfDay) {
      margin = 5;
    }

    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: margin),
      child: child,
    );
  }
}
