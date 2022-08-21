import 'package:ezstudies/database_helper.dart';
import 'package:ezstudies/templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../timestamp_utils.dart';
import 'agenda_cell_data.dart';

class Details extends StatelessWidget {
  const Details(this.data, {Key? key}) : super(key: key);
  final AgendaCellData data;
  static late AgendaCellData newData;
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
        label: AppLocalizations.of(context)!.date,
        icon: const Icon(Icons.calendar_month),
        date: DateTime.fromMillisecondsSinceEpoch(newData.start));
    TimeInput start = TimeInput(
        label: AppLocalizations.of(context)!.start,
        icon: const Icon(Icons.access_time),
        date: DateTime.fromMillisecondsSinceEpoch(newData.start));
    TimeInput end = TimeInput(
        label: AppLocalizations.of(context)!.end,
        icon: const Icon(Icons.access_time_filled),
        date: DateTime.fromMillisecondsSinceEpoch(newData.end));

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
            newData.start = DateTime(dateTime.year, dateTime.month, dateTime.day, startTime.hour, startTime.minute, 0, 0, 0).millisecondsSinceEpoch;
            newData.end = DateTime(dateTime.year, dateTime.month, dateTime.day, endTime.hour, endTime.minute, 0, 0, 0).millisecondsSinceEpoch;
            DatabaseHelper database = DatabaseHelper();
            database.open().then((_) {
              if (newData.added == 0) {
                if (newData.edited == 0) {
                  newData.edited = 1;
                  database
                      .insertOrReplace(DatabaseHelper.backup, data)
                      .then((value) => database
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
                        print("error");
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

class TimeInput extends StatefulWidget {
  TimeInput(
      {Key? key, required this.label, required this.icon, required this.date})
      : super(key: key);
  final String label;
  final Icon icon;
  DateTime date;

  @override
  State<TimeInput> createState() => _TimeInputState();

  DateTime getDate() {
    return date;
  }
}

class _TimeInputState extends State<TimeInput> {
  late String text = DateFormat("HH:mm", getLocale()).format(widget.date);
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(getLocale(), null);
    return TextFormField(
      decoration: InputDecoration(
          label: Text(widget.label),
          hintText: widget.label.toLowerCase(),
          icon: widget.icon),
      controller: TextEditingController(text: text),
      onTap: () {
        showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(widget.date))
            .then((value) {
          if (value != null) {
            widget.date = DateTime(widget.date.year, widget.date.month,
                widget.date.day, value.hour, value.minute, 0, 0, 0);
            setState(() {
              text = DateFormat("HH:mm", getLocale()).format(widget.date);
            });
          }
        });
      },
    );
  }
}

class DateInput extends StatefulWidget {
  DateInput(
      {Key? key, required this.label, required this.icon, required this.date})
      : super(key: key);
  final String label;
  final Icon icon;
  DateTime date;

  @override
  State<DateInput> createState() => _DateInputState();

  DateTime getDate() {
    return date;
  }
}

class _DateInputState extends State<DateInput> {
  late String text = DateFormat("EEEE, d MMMM y", getLocale()).format(widget.date);
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(getLocale(), null);
    return TextFormField(
      decoration: InputDecoration(
          label: Text(widget.label),
          hintText: widget.label.toLowerCase(),
          icon: widget.icon),
      controller: TextEditingController(text: text),
      onTap: () {
        showDatePicker(
                context: context,
                initialDate: widget.date,
                lastDate: DateTime(
                    widget.date.year, widget.date.month + 1, widget.date.day),
                firstDate: DateTime(
                    widget.date.year, widget.date.month - 1, widget.date.day))
            .then((value) {
          if (value != null) {
            widget.date = DateTime(value.year, value.month,
                value.day, widget.date.hour, widget.date.minute, 0, 0, 0);
            setState(() {
              text = DateFormat("EEEE, d MMMM y", getLocale()).format(widget.date);
            });
          }
        });
      },
    );
  }
}
