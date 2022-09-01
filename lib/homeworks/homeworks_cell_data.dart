import 'package:flutter/material.dart';

import '../utils/style.dart';

class HomeworksCellData {
  String id;
  String description;
  int date;
  int done;

  HomeworksCellData(
      {required this.id,
      required this.description,
      required this.date,
      this.done = 0});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "description": description,
      "date": date,
      "done": done,
    };
  }

  Color getColor() {
    int value = 0;
    for (int i = 0; i < description.length; i++) {
      value += description.codeUnitAt(i);
    }
    value = (value % Colors.primaries.length).toInt();
    return (Style.theme == 0)
        ? Colors.primaries[value].shade400
        : Colors.primaries[value].shade700;
  }
}
