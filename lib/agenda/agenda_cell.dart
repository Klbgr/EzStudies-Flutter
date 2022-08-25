import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../utils/templates.dart';
import '../utils/timestamp_utils.dart';
import 'agenda_cell_data.dart';
import 'details.dart';

class AgendaCell extends StatelessWidget {
  const AgendaCell(this.data, this.firstOfDay, this.firstOfMonth, this.onClose,
      this.openable, this.editable,
      {Key? key})
      : super(key: key);
  final bool firstOfDay;
  final bool firstOfMonth;
  final AgendaCellData data;
  final Function onClose;
  final bool openable;
  final bool editable;

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
      children.add(const Icon(Icons.person, size: 16));
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

    if (openable) {
      child =
          OpenContainerTemplate(child, Details(data, editable: editable), () {
        onClose();
      });
    }

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
