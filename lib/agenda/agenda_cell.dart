import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../utils/style.dart';
import '../utils/templates.dart';
import '../utils/timestamp_utils.dart';
import 'agenda_cell_data.dart';
import 'agenda_details.dart';

class AgendaCell extends StatelessWidget {
  const AgendaCell(
      {required this.data,
      this.firstOfDay = false,
      this.firstOfMonth = false,
      required this.onClosed,
      this.editable = true,
      this.search = false,
      Key? key})
      : super(key: key);
  final bool firstOfDay;
  final bool firstOfMonth;
  final AgendaCellData data;
  final Function onClosed;
  final bool editable;
  final bool search;

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(getLocale(), null);

    String start = timestampToTime(data.start);
    String end = timestampToTime(data.end);
    bool today = isSameDay(data.start, DateTime.now().millisecondsSinceEpoch);

    Color color = data.getColor();

    Widget child = Row(children: [
      Container(
        margin: const EdgeInsets.only(right: 20),
        alignment: Alignment.center,
        width: 35,
        child: Column(
            children: (firstOfDay)
                ? [
                    Text(timestampToWeekDay(data.start),
                        style: TextStyle(
                            color: (today) ? Style.primary : Style.text)),
                    ClipOval(
                        child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                                alignment: Alignment.center,
                                color: (today)
                                    ? Style.primary
                                    : Colors.transparent,
                                child: Text(
                                    timestampToDayOfMonth(data.start)
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 20, color: Style.text))))),
                  ]
                : List.empty()),
      ),
      Expanded(
          child: OpenContainerTemplate(
              child1: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16))),
                  child: Column(children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text("$start - $end",
                          style: TextStyle(
                              color: Style.text, fontWeight: FontWeight.bold)),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                              child: Text(
                            data.description,
                            style: TextStyle(color: Style.text),
                            maxLines: null,
                            overflow: TextOverflow.ellipsis,
                          )),
                          if (data.added == 0 && data.edited == 1)
                            Icon(Icons.edit, size: 16, color: Style.text)
                          else if (data.added == 1)
                            Icon(Icons.person, size: 16, color: Style.text)
                        ])
                  ])),
              child2:
                  AgendaDetails(data: data, editable: editable, search: search),
              onClosed: () => onClosed(),
              radius: const BorderRadius.all(Radius.circular(16)),
              color: color))
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

    return Container(
      margin: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 5,
          top: (firstOfMonth || firstOfDay) ? 10 : 0),
      child: child,
    );
  }
}
