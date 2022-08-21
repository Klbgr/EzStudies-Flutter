import 'package:ezstudies/agenda/trash.dart';
import 'package:ezstudies/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../templates.dart';
import '../timestamp_utils.dart';
import 'add.dart';
import 'agenda_cell_data.dart';
import 'details.dart';

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
    OpenContainerTemplate reset = OpenContainerTemplate(
        Text(AppLocalizations.of(context)!.reset, style: menuStyle),
        Text(AppLocalizations.of(context)!.reset),
        () => load());

    OpenContainerTemplate help = OpenContainerTemplate(
        Text(AppLocalizations.of(context)!.help, style: menuStyle),
        Text(AppLocalizations.of(context)!.help),
        () => load());

    Widget menu = MenuTemplate(<PopupMenuItem<String>>[
      PopupMenuItem<String>(value: "trash", child: trash),
      PopupMenuItem<String>(value: "reset", child: reset),
      PopupMenuItem<String>(value: "help", child: help)
    ], (value) {
      switch (value) {
        case "trash":
          trash.getTrigger().call();
          break;
        case "reset":
          reset.getTrigger().call();
          break;
        case "help":
          help.getTrigger().call();
          break;
      }
    });

    OpenContainerTemplate add = OpenContainerTemplate(
        Row(
          children: [
            Container(margin: const EdgeInsets.only(right: 10), child: const Icon(Icons.add, color: Colors.white,)),
            Text(
              AppLocalizations.of(context)!.add,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
        const Add(),
        () => load());

    Widget child = Stack(
      children: [
        RefreshIndicator(
            onRefresh: () => refresh(),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: list.length,
              itemBuilder: (context, index) {
                var data = list[index];
                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    remove(data);
                  },
                  background: Container(color: Colors.red),
                  child: _AgendaCell(
                      this,
                      data,
                      index == 0 ||
                          !isSameDay(data.start, list[index - 1].start),
                      index == 0 ||
                          !isSameMonth(data.start, list[index - 1].start)),
                );
              },
            )),
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

  /*
  void add(String id, String title, String description, int start, int end) {
    CellData data = CellData(
      id: id,
      title: title,
      description: description,
      start: start,
      end: end,
      added: 1,
    );
    DatabaseHelper database = DatabaseHelper();
    database.open().then((value) => database
        .insert(DatabaseHelper.agenda, data)
        .then((value) => database.close()));
    if (!list.any((element) => element.id == data.id)) {
      setState(() => list.add(data));
    } else {
      //error
    }
  }
   */

  void remove(AgendaCellData data) {
    data.trashed = 1;
    DatabaseHelper database = DatabaseHelper();
    database.open().then((value) => database
        .insertOrReplace(DatabaseHelper.agenda, data)
        .then((value) => database.close()));
    setState(() => list.remove(data));
  }

  Future<void> refresh() async {}
}

class _AgendaCell extends StatelessWidget {
  const _AgendaCell(this.parent, this.data, this.firstOfDay, this.firstOfMonth,
      {Key? key})
      : super(key: key);
  final _AgendaState parent;
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
      description = " ($description)";
    }

    String tag = "";
    if (data.added == 1) {
      tag = " (Added)";
    } else if (data.edited == 1) {
      tag = " (Edited)";
    }

    List<Text> date = <Text>[];
    if (firstOfDay) {
      date = [
        Text(timestampToWeekDay(data.start)),
        Text(timestampToDayOfMonth(data.start).toString(),
            style: const TextStyle(fontSize: 20))
      ];
    }

    Widget child1 = Row(children: [
      Container(
        alignment: Alignment.center,
        width: 30,
        child: Column(children: date),
      ),
      Expanded(
          child: Container(
              margin: const EdgeInsets.only(left: 20),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Column(children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 2.5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.title + tag,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "$start - $end$description",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ])))
    ]);

    Widget child2 = Details(data);

    Widget child = OpenContainerTemplate(child1, child2, () => parent.load());

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
