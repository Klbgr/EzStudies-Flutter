import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../timestamp_utils.dart';

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
