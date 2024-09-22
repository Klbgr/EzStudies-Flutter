import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

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
      super.key});

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
                        style: (today)
                            ? TextStyle(
                                color: Theme.of(context).colorScheme.primary)
                            : null),
                    ClipOval(
                        child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                                alignment: Alignment.center,
                                color: (today)
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                child: Text(
                                    timestampToDayOfMonth(data.start)
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: (today)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .surface
                                            : null))))),
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
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                              child: Text(
                            data.description,
                            maxLines: null,
                            overflow: TextOverflow.ellipsis,
                          )),
                          if (data.added == 0 && data.edited == 1)
                            const Icon(Icons.edit, size: 16)
                          else if (data.added == 1)
                            const Icon(Icons.person, size: 16)
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
            style: const TextStyle(fontSize: 20),
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
