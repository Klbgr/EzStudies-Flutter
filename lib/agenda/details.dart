import 'package:ezstudies/agenda/time_input.dart';
import 'package:ezstudies/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/templates.dart';
import 'agenda_cell_data.dart';
import 'date_input.dart';

class Details extends StatelessWidget {
  Details(this.data, {Key? key}) : super(key: key);
  final AgendaCellData data;
  late AgendaCellData newData;
  final EdgeInsetsGeometry margin = const EdgeInsets.only(bottom: 20);

  @override
  Widget build(BuildContext context) {
    newData = AgendaCellData(
        id: data.id,
        title: data.title,
        description: data.description,
        start: data.start,
        end: data.end,
        added: data.added,
        edited: data.edited,
        trashed: data.trashed);

    String source = AppLocalizations.of(context)!.internet;
    if (newData.added == 1) {
      source = AppLocalizations.of(context)!.user;
    }

    DateInput date = DateInput(
        AppLocalizations.of(context)!.date,
        const Icon(Icons.calendar_month),
        DateTime.fromMillisecondsSinceEpoch(newData.start));
    TimeInput start = TimeInput(
        AppLocalizations.of(context)!.start,
        const Icon(Icons.access_time),
        DateTime.fromMillisecondsSinceEpoch(newData.start));
    TimeInput end = TimeInput(
        AppLocalizations.of(context)!.end,
        const Icon(Icons.access_time_filled),
        DateTime.fromMillisecondsSinceEpoch(newData.end));

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
      Container(
          alignment: Alignment.centerLeft,
          margin: margin,
          child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.source),
                hintText: AppLocalizations.of(context)!.source.toLowerCase(),
                icon: const Icon(Icons.info_outline)),
            initialValue: source,
          ))
    ];

    if (newData.added == 0) {
      String edited = AppLocalizations.of(context)!.no;
      if (newData.edited == 1) {
        edited = AppLocalizations.of(context)!.yes;
      }
      form.add(Container(
          alignment: Alignment.centerLeft,
          margin: margin,
          child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.edited),
                hintText: AppLocalizations.of(context)!.edited.toLowerCase(),
                icon: const Icon(Icons.edit)),
            initialValue: edited,
          )));
    }

    List<Widget> buttons = <Widget>[
      FloatingActionButton.extended(
          backgroundColor: Colors.green,
          icon: const Icon(Icons.save),
          onPressed: () {
            DateTime dateTime = date.getDate();
            TimeOfDay startTime = TimeOfDay.fromDateTime(start.getDate());
            TimeOfDay endTime = TimeOfDay.fromDateTime(end.getDate());
            newData.start = DateTime(dateTime.year, dateTime.month,
                    dateTime.day, startTime.hour, startTime.minute, 0, 0, 0)
                .millisecondsSinceEpoch;
            newData.end = DateTime(dateTime.year, dateTime.month, dateTime.day,
                    endTime.hour, endTime.minute, 0, 0, 0)
                .millisecondsSinceEpoch;
            DatabaseHelper database = DatabaseHelper();
            database.open().then((_) {
              if (newData.added == 0) {
                if (newData.edited == 0) {
                  newData.edited = 1;
                  database.insertOrReplace(DatabaseHelper.backup, data).then(
                      (value) => database
                          .insertOrReplace(DatabaseHelper.agenda, newData)
                          .then((value) => database
                              .close()
                              .then((value) => Navigator.pop(context))));
                } else {
                  database.insertOrReplace(DatabaseHelper.agenda, newData).then(
                      (value) => database
                          .close()
                          .then((value) => Navigator.pop(context)));
                }
              } else {
                database.insertOrReplace(DatabaseHelper.agenda, newData).then(
                    (value) => database
                        .close()
                        .then((value) => Navigator.pop(context)));
              }
            });
          },
          label: Text(AppLocalizations.of(context)!.save))
    ];

    if (newData.added == 0 && newData.edited == 1) {
      buttons.insert(
          0,
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: FloatingActionButton.extended(
                backgroundColor: Colors.red,
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  AgendaCellData backup;
                  DatabaseHelper database = DatabaseHelper();
                  database.open().then((_) {
                    database
                        .getById(DatabaseHelper.backup, newData.id)
                        .then((value) {
                      if (value.isEmpty) {
                        //TODO: error
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialogTemplate(
                              AppLocalizations.of(context)!.error, "error", [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(AppLocalizations.of(context)!.ok))
                          ]),
                        );
                        database.close();
                      } else {
                        backup = value[0];
                        database
                            .insertOrReplace(DatabaseHelper.agenda, backup)
                            .then((value) => database
                                    .delete(DatabaseHelper.backup, backup)
                                    .then((value) {
                                  database
                                      .close()
                                      .then((value) => Navigator.pop(context));
                                }));
                      }
                    });
                  });
                },
                label: Text(AppLocalizations.of(context)!.reset)),
          ));
    }

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buttons,
          ),
        )
      ],
    );

    return Template(AppLocalizations.of(context)!.details, child, null, true);
  }
}
