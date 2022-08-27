import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../utils/style.dart';
import '../utils/timestamp_utils.dart';

class TimeInput extends StatefulWidget {
  const TimeInput(this.label, this.icon, this.date,
      {this.editable = true, required this.onChanged, Key? key})
      : super(key: key);
  final String label;
  final IconData icon;
  final DateTime date;
  final bool editable;
  final Function(int) onChanged;

  @override
  State<TimeInput> createState() => _TimeInputState();
}

class _TimeInputState extends State<TimeInput> {
  late DateTime date = widget.date;

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(getLocale(), null);
    return TextFormField(
      enabled: widget.editable,
      readOnly: true,
      cursorColor: Style.primary,
      style: TextStyle(color: Style.text),
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Style.primary),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Style.hint),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Style.hint),
        ),
        hintText: widget.label.toLowerCase(),
        hintStyle: TextStyle(color: Style.hint),
        label: Text(widget.label, style: TextStyle(color: Style.hint)),
        icon: Icon(widget.icon, color: Style.primary),
      ),
      controller: TextEditingController(
          text: DateFormat("HH:mm", getLocale()).format(date)),
      onTap: () {
        showTimePicker(
                context: context, initialTime: TimeOfDay.fromDateTime(date))
            .then((value) {
          if (value != null) {
            setState(() {
              date = DateTime(date.year, date.month, date.day, value.hour,
                  value.minute, 0, 0, 0);
            });
            widget.onChanged(date.millisecondsSinceEpoch);
          }
        });
      },
    );
  }
}
