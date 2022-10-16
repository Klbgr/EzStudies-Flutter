import 'package:ezstudies/agenda/agenda_cell_data.dart';
import 'package:ezstudies/agenda/agenda_details.dart';
import 'package:ezstudies/utils/templates.dart';
import 'package:flutter/material.dart';

import '../utils/style.dart';
import '../utils/timestamp_utils.dart';

class AgendaWeekViewCell extends StatelessWidget {
  const AgendaWeekViewCell({required this.data, Key? key}) : super(key: key);
  final AgendaCellData data;

  @override
  Widget build(BuildContext context) {
    String start = timestampToTime(data.start);
    String end = timestampToTime(data.end);
    Color color = data.getColor();
    return Container(
        margin: const EdgeInsets.all(1),
        child: OpenContainerTemplate(
            child1: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.all(Radius.circular(16))),
                child: Column(children: [
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text("$start - $end",
                          style: TextStyle(
                              color: Style.text, fontWeight: FontWeight.bold))),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text(data.description,
                          style: TextStyle(color: Style.text),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis))
                ])),
            child2: AgendaDetails(data: data, editable: false),
            color: color,
            elevation: 0,
            radius: const BorderRadius.all(Radius.circular(16))));
  }
}
