import 'package:ezstudies/agenda/time_input.dart';
import 'package:ezstudies/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/templates.dart';
import 'agenda_cell_data.dart';
import 'date_input.dart';

class Add extends StatelessWidget {
  Add({Key? key}) : super(key: key);
  AgendaCellData newData = AgendaCellData(
    id: "",
    title: "",
    description: "",
    start: DateTime.now().millisecondsSinceEpoch,
    end: DateTime.now().millisecondsSinceEpoch,
    added: 1,
    edited: 0,
    trashed: 0,
  );

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry margin = const EdgeInsets.only(bottom: 20);

    DateInput date = DateInput(AppLocalizations.of(context)!.date,
        const Icon(Icons.calendar_month), DateTime.now());
    TimeInput start = TimeInput(AppLocalizations.of(context)!.start,
        const Icon(Icons.access_time), DateTime.now());
    TimeInput end = TimeInput(AppLocalizations.of(context)!.end,
        const Icon(Icons.access_time_filled), DateTime.now());

    List<Widget> form = <Container>[
      Container(
          alignment: Alignment.centerLeft,
          margin: margin,
          child: TextFormField(
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.title),
                  hintText: AppLocalizations.of(context)!.title.toLowerCase(),
                  icon: const Icon(Icons.title)),
              initialValue: newData.title,
              onChanged: (value) => newData.title = value)),
      Container(
          alignment: Alignment.centerLeft,
          margin: margin,
          child: TextFormField(
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.description),
                  hintText:
                      AppLocalizations.of(context)!.description.toLowerCase(),
                  icon: const Icon(Icons.description)),
              initialValue: newData.description,
              onChanged: (value) => newData.description = value)),
      Container(alignment: Alignment.centerLeft, margin: margin, child: date),
      Container(alignment: Alignment.centerLeft, margin: margin, child: start),
      Container(alignment: Alignment.centerLeft, margin: margin, child: end),
    ];

    Widget child = Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(children: form)))),
        Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton.extended(
                backgroundColor: Colors.green,
                icon: const Icon(Icons.add),
                onPressed: () {
                  DateTime dateTime = date.getDate();
                  TimeOfDay startTime = TimeOfDay.fromDateTime(start.getDate());
                  TimeOfDay endTime = TimeOfDay.fromDateTime(end.getDate());
                  newData.start = DateTime(
                          dateTime.year,
                          dateTime.month,
                          dateTime.day,
                          startTime.hour,
                          startTime.minute,
                          0,
                          0,
                          0)
                      .millisecondsSinceEpoch;
                  newData.end = DateTime(dateTime.year, dateTime.month,
                          dateTime.day, endTime.hour, endTime.minute, 0, 0, 0)
                      .millisecondsSinceEpoch;
                  newData.id = newData.title + newData.start.toString();
                  DatabaseHelper database = DatabaseHelper();
                  database.open().then((_) => database
                          .insert(DatabaseHelper.agenda, newData)
                          .then((value) {
                        if (!value) {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialogTemplate(
                                      AppLocalizations.of(context)!.error,
                                      "error", [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                            AppLocalizations.of(context)!.ok))
                                  ]));
                          database.close();
                        } else {
                          database
                              .close()
                              .then((value) => Navigator.pop(context));
                        }
                      }));
                },
                label: Text(AppLocalizations.of(context)!.add)))
      ],
    );

    return Template(AppLocalizations.of(context)!.add, child, null, true);
  }
}
