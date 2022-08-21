
import 'package:ezstudies/database_helper.dart';
import 'package:ezstudies/templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    Widget child = ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: list.length,
      itemBuilder: (context, index) {
        var data = list[index];
        return Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) {
            restore(data);
          },
          background: Container(color: Colors.green),
          child: Text(data.title),
        );
      },
    );

    return Template(AppLocalizations.of(context)!.trash, child, null, true);
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
