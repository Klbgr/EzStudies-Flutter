import 'package:ezstudies/homeworks/homeworks_cell_data.dart';
import 'package:ezstudies/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/style.dart';
import '../utils/templates.dart';

class HomeworksDetails extends StatelessWidget {
  const HomeworksDetails({this.data, this.add = false, Key? key})
      : super(key: key);
  final HomeworksCellData? data;
  final bool add;
  final EdgeInsetsGeometry margin = const EdgeInsets.only(top: 10, bottom: 10);

  @override
  Widget build(BuildContext context) {
    HomeworksCellData newData;
    if (add) {
      newData = HomeworksCellData(
          id: "",
          description: "",
          date: DateTime.now().millisecondsSinceEpoch,
          done: 0);
    } else {
      newData = HomeworksCellData(
          id: data!.id,
          description: data!.description,
          date: data!.date,
          done: data!.done);
    }

    List<Widget> form = <Widget>[
      Container(
          alignment: Alignment.centerLeft,
          margin: margin,
          child: TextFormFieldTemplate(
              AppLocalizations.of(context)!.description, Icons.description,
              initialValue: newData.description,
              onChanged: (value) => newData.description = value,
              multiline: true)),
      Container(
          alignment: Alignment.centerLeft,
          margin: margin,
          child: TextFormFieldTemplate(
              AppLocalizations.of(context)!.date, Icons.calendar_month,
              dateTime: DateTime.fromMillisecondsSinceEpoch(newData.date),
              date: true, onTapped: (value) {
            DateTime date = DateTime.fromMillisecondsSinceEpoch(newData.date);
            DateTime newDate = DateTime.fromMillisecondsSinceEpoch(value);
            newData.date = DateTime(newDate.year, newDate.month, newDate.day,
                    date.hour, date.minute, 0, 0, 0)
                .millisecondsSinceEpoch;
          })),
      Container(
          alignment: Alignment.centerLeft,
          margin: margin,
          child: TextFormFieldTemplate(
              AppLocalizations.of(context)!.time, Icons.access_time,
              dateTime: DateTime.fromMillisecondsSinceEpoch(newData.date),
              time: true, onTapped: (value) {
            DateTime date = DateTime.fromMillisecondsSinceEpoch(newData.date);
            DateTime time = DateTime.fromMillisecondsSinceEpoch(value);
            newData.date = DateTime(date.year, date.month, date.day, time.hour,
                    time.minute, 0, 0, 0)
                .millisecondsSinceEpoch;
          })),
    ];

    Widget child = Column(children: [
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
              icon: Icon(add ? Icons.add : Icons.save, color: Style.text),
              onPressed: () {
                DateTime date =
                    DateTime.fromMillisecondsSinceEpoch(newData.date);
                newData.date = DateTime(date.year, date.month, date.day,
                        date.hour, date.minute, 0, 0, 0)
                    .millisecondsSinceEpoch;
                if (newData.description.isEmpty) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialogTemplate(
                              AppLocalizations.of(context)!.error,
                              AppLocalizations.of(context)!.error_empty, [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(AppLocalizations.of(context)!.ok))
                          ]));
                } else if (add) {
                  newData.id = newData.description + newData.date.toString();
                  DatabaseHelper database = DatabaseHelper();
                  database.open().then((value) {
                    database.insertHomeworks(newData).then((value) {
                      if (!value) {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialogTemplate(
                                    AppLocalizations.of(context)!.error,
                                    AppLocalizations.of(context)!
                                        .error_conflict,
                                    [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                              AppLocalizations.of(context)!.ok))
                                    ]));
                        database.close();
                      } else {
                        database
                            .close()
                            .then((value) => Navigator.pop(context));
                      }
                    });
                  });
                } else {
                  DatabaseHelper database = DatabaseHelper();
                  database.open().then((value) {
                    database.insertOrReplaceHomeworks(newData).then((value) =>
                        database
                            .close()
                            .then((value) => Navigator.pop(context)));
                  });
                }
              },
              label: Text(
                  add
                      ? AppLocalizations.of(context)!.add
                      : AppLocalizations.of(context)!.save,
                  style: TextStyle(color: Style.text))))
    ]);

    return Template(AppLocalizations.of(context)!.details, child, back: true);
  }
}
