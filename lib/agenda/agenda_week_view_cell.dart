import 'package:ezstudies/agenda/agenda_cell_data.dart';
import 'package:ezstudies/agenda/agenda_details.dart';
import 'package:ezstudies/utils/templates.dart';
import 'package:flutter/material.dart';

import '../utils/style.dart';
import '../utils/timestamp_utils.dart';

class AgendaWeekViewCell extends StatefulWidget {
  const AgendaWeekViewCell(
      {required this.data, this.onClosed, this.onOpened, super.key});
  final AgendaCellData data;
  final Function? onClosed;
  final Function? onOpened;

  @override
  State<AgendaWeekViewCell> createState() => _AgendaWeekViewCellState();
}

class _AgendaWeekViewCellState extends State<AgendaWeekViewCell> {
  @override
  Widget build(BuildContext context) {
    String start = timestampToTime(widget.data.start);
    String end = timestampToTime(widget.data.end);
    Color color = widget.data.getColor();
    return Container(
        margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
        child: OpenContainerTemplate(
            child1: Container(
                padding: const EdgeInsets.all(7.5),
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.all(Radius.circular(16))),
                child: Column(children: [
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text("$start - $end",
                          style: TextStyle(
                              color: Style.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 10))),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text(widget.data.description,
                          style: TextStyle(color: Style.text, fontSize: 10),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis))
                ])),
            child2: AgendaDetails(
                data: widget.data,
                editable: false,
                onClosed: widget.onClosed,
                onOpened: widget.onOpened),
            color: color,
            elevation: 0,
            radius: const BorderRadius.all(Radius.circular(16))));
  }
}
