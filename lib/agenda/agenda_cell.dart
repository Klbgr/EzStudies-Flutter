import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../utils/style.dart';
import '../utils/templates.dart';
import '../utils/timestamp_utils.dart';
import 'agenda_cell_data.dart';
import 'details.dart';

class AgendaCell extends StatelessWidget {
  const AgendaCell(this.data, this.firstOfDay, this.firstOfMonth,
      {required this.onClosed,
      this.editable = true,
      this.add = false,
      Key? key})
      : super(key: key);
  final bool firstOfDay;
  final bool firstOfMonth;
  final AgendaCellData data;
  final Function onClosed;
  final bool editable;
  final bool add;

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(getLocale(), null);

    String start = timestampToTime(data.start);
    String end = timestampToTime(data.end);
    String description = data.description;
    if (description != "") {
      description = "($description)";
    }

    List<Widget> date = <Text>[];
    if (firstOfDay) {
      bool today = isSameDay(data.start, DateTime.now().millisecondsSinceEpoch);

      date = [
        Text(timestampToWeekDay(data.start),
            style: TextStyle(color: (today) ? Style.primary : Style.text)),
        ClipOval(
            child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                    alignment: Alignment.center,
                    color: (today) ? Style.primary : Colors.transparent,
                    child: Text(timestampToDayOfMonth(data.start).toString(),
                        style: TextStyle(fontSize: 20, color: Style.text))))),
      ];
    }
    List<Widget> children = [
      Flexible(
          child: Text(
        data.title,
        style: TextStyle(fontWeight: FontWeight.bold, color: Style.text),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ))
    ];

    if (data.added == 0 && data.edited == 1) {
      children.add(Icon(Icons.edit, size: 16, color: Style.text));
    } else if (data.added == 1) {
      children.add(Icon(Icons.person, size: 16, color: Style.text));
    }

    Widget child = Row(children: [
      Container(
        margin: const EdgeInsets.only(right: 20),
        alignment: Alignment.center,
        width: 35,
        child: Column(children: date),
      ),
      Expanded(
          child: OpenContainerTemplate(
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: data.getColor(),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16))),
                  child: Column(children: [
                    Container(
                        margin: const EdgeInsets.only(bottom: 2.5),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: children)),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text("$start - $end $description",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Style.text)),
                    ),
                  ])),
              Details(data: data, editable: editable, add: add), () {
        onClosed();
      },
              radius: const BorderRadius.all(Radius.circular(16)),
              color: data.getColor(),
              trigger: (_) {}))
    ]);

    if (firstOfMonth) {
      child = Column(children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(left: 50, top: 15, bottom: 10),
          child: Text(
            timestampToMonthYear(data.start),
            style: TextStyle(fontSize: 20, color: Style.text),
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
