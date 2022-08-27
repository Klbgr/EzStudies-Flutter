import 'package:flutter/material.dart';

import '../utils/style.dart';

class AgendaCellData {
  String id;
  String title;
  String description;
  int start;
  int end;
  int added;
  int edited;
  int trashed;

  AgendaCellData({
    required this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    this.added = 0,
    this.edited = 0,
    this.trashed = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "start": start,
      "end": end,
      "added": added,
      "edited": edited,
      "trashed": trashed,
    };
  }

  Color getColor() {
    int value = 0;
    for (int i = 0; i < title.length; i++) {
      value += title.codeUnitAt(i);
    }
    value = (value % Colors.primaries.length).toInt();
    return (Style.theme == 0)
        ? Colors.primaries[value].shade400
        : Colors.primaries[value].shade700;
  }
}
