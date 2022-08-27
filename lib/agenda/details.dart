import 'package:ezstudies/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/style.dart';
import '../utils/templates.dart';
import 'agenda_cell_data.dart';

class Details extends StatelessWidget {
  Details({this.add = false, this.data, this.editable = true, Key? key})
      : super(key: key);
  final bool add;
  final AgendaCellData? data;
  late AgendaCellData newData;
  final bool editable;
  final EdgeInsetsGeometry margin = const EdgeInsets.only(bottom: 20);

  @override
  Widget build(BuildContext context) {
    if (add) {
      newData = AgendaCellData(
        id: "",
        title: "",
        description: "",
        start: DateTime.now().millisecondsSinceEpoch,
        end: DateTime.now()
            .add(const Duration(minutes: 1))
            .millisecondsSinceEpoch,
        added: 1,
        edited: 0,
        trashed: 0,
      );
    } else {
      newData = AgendaCellData(
          id: data!.id,
          title: data!.title,
          description: data!.description,
          start: data!.start,
          end: data!.end,
          added: data!.added,
          edited: data!.edited,
          trashed: data!.trashed);
    }

    List<Widget> form = <Widget>[
      Container(
          alignment: Alignment.centerLeft,
          margin: margin,
          child: TextFormFieldTemplate(
              AppLocalizations.of(context)!.title, Icons.title,
              initialValue: newData.title,
              onChanged: (value) => newData.title = value,
              enabled: editable)),
      Container(
          alignment: Alignment.centerLeft,
          margin: margin,
          child: TextFormFieldTemplate(
              AppLocalizations.of(context)!.description, Icons.description,
              initialValue: newData.description,
              onChanged: (value) => newData.description = value,
              enabled: editable)),
      Container(
          alignment: Alignment.centerLeft,
          margin: margin,
          child: TextFormFieldTemplate(
              AppLocalizations.of(context)!.date, Icons.calendar_month,
              dateTime: DateTime.fromMillisecondsSinceEpoch(newData.start),
              date: true,
              onTapped: (value) => newData.start = value,
              enabled: editable)),
      Container(
          alignment: Alignment.centerLeft,
          margin: margin,
          child: TextFormFieldTemplate(
              AppLocalizations.of(context)!.start, Icons.access_time,
              dateTime: DateTime.fromMillisecondsSinceEpoch(newData.start),
              time: true,
              onTapped: (value) => newData.start = value,
              enabled: editable)),
      Container(
          alignment: Alignment.centerLeft,
          margin: margin,
          child: TextFormFieldTemplate(
              AppLocalizations.of(context)!.end, Icons.access_time_filled,
              dateTime: DateTime.fromMillisecondsSinceEpoch(newData.end),
              time: true,
              onTapped: (value) => newData.end = value,
              enabled: editable)),
    ];

    if (!add) {
      form.add(Container(
          alignment: Alignment.centerLeft,
          margin: margin,
          child: TextFormFieldTemplate(
              AppLocalizations.of(context)!.source, Icons.info_outline,
              initialValue: (newData.added == 1)
                  ? AppLocalizations.of(context)!.user
                  : AppLocalizations.of(context)!.internet,
              onChanged: (_) {},
              enabled: false)));
      if (newData.added == 0) {
        form.add(Container(
            alignment: Alignment.centerLeft,
            margin: margin,
            child: TextFormField(
              enabled: false,
              cursorColor: Style.primary,
              style: TextStyle(color: Style.text),
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Style.primary),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Style.hint),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Style.hint),
                ),
                hintText: AppLocalizations.of(context)!.edited.toLowerCase(),
                hintStyle: TextStyle(color: Style.hint),
                label: Text(AppLocalizations.of(context)!.edited,
                    style: TextStyle(color: Style.hint)),
                icon: Icon(Icons.edit, color: Style.primary),
              ),
              initialValue: (newData.edited == 1)
                  ? AppLocalizations.of(context)!.yes
                  : AppLocalizations.of(context)!.no,
            )));
      }
    }

    List<Widget> column = [
      Expanded(
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(children: form))))
    ];

    if (editable || add) {
      List<Widget> buttons = <Widget>[
        FloatingActionButton.extended(
            backgroundColor: Colors.green,
            icon: Icon(add ? Icons.add : Icons.save, color: Style.text),
            onPressed: () {
              if (newData.title.isEmpty) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialogTemplate(
                            AppLocalizations.of(context)!.error,
                            "title empty", [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context)!.ok))
                        ]));
              } else if (newData.end <= newData.start) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialogTemplate(
                            AppLocalizations.of(context)!.error,
                            "error end <= start", [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context)!.ok))
                        ]));
              } else {
                if (add) {
                  DateTime start =
                      DateTime.fromMillisecondsSinceEpoch(newData.start);
                  DateTime end =
                      DateTime.fromMillisecondsSinceEpoch(newData.end);
                  newData.end = DateTime(start.year, start.month, start.day,
                          end.hour, end.minute, 0, 0, 0)
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
                } else {
                  DatabaseHelper database = DatabaseHelper();
                  database.open().then((_) {
                    if (newData.added == 0) {
                      if (newData.edited == 0) {
                        newData.edited = 1;
                        database
                            .insertOrReplace(DatabaseHelper.backup, data!)
                            .then((value) => database
                                .insertOrReplace(DatabaseHelper.agenda, newData)
                                .then((value) => database
                                    .close()
                                    .then((value) => Navigator.pop(context))));
                      } else {
                        database
                            .insertOrReplace(DatabaseHelper.agenda, newData)
                            .then((value) => database
                                .close()
                                .then((value) => Navigator.pop(context)));
                      }
                    } else {
                      database
                          .insertOrReplace(DatabaseHelper.agenda, newData)
                          .then((value) => database
                              .close()
                              .then((value) => Navigator.pop(context)));
                    }
                  });
                }
              }
            },
            label: Text(
                add
                    ? AppLocalizations.of(context)!.add
                    : AppLocalizations.of(context)!.save,
                style: TextStyle(color: Style.text))),
      ];

      if (newData.added == 0 && newData.edited == 1 && !add) {
        buttons.insert(
            0,
            Container(
              margin: const EdgeInsets.only(right: 20),
              child: FloatingActionButton.extended(
                  backgroundColor: Colors.red,
                  icon: Icon(Icons.refresh, color: Style.text),
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
                                    database.close().then(
                                        (value) => Navigator.pop(context));
                                  }));
                        }
                      });
                    });
                  },
                  label: Text(AppLocalizations.of(context)!.reset,
                      style: TextStyle(color: Style.text))),
            ));
      }

      column.add(Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttons,
        ),
      ));
    }

    Widget child = Column(
      children: column,
    );

    return Template(
        add
            ? AppLocalizations.of(context)!.add
            : AppLocalizations.of(context)!.details,
        child,
        back: true);
  }
}
