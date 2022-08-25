import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../utils/timestamp_utils.dart';

class DateInput extends StatefulWidget {
  DateInput(this.label, this.icon, this.date, {Key? key}) : super(key: key);
  final String label;
  final Icon icon;
  DateTime date;

  @override
  State<DateInput> createState() => _DateInputState();

  DateTime getDate() {
    return date;
  }
}

class _DateInputState extends State<DateInput> {
  late String text =
      DateFormat("EEEE, d MMMM y", getLocale()).format(widget.date);

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(getLocale(), null);
    DateTime date =
        DateTime(widget.date.year, widget.date.month, widget.date.day);
    return TextFormField(
      decoration: InputDecoration(
          label: Text(widget.label),
          hintText: widget.label.toLowerCase(),
          icon: widget.icon),
      controller: TextEditingController(text: text),
      onTap: () {
        showDatePicker(
                context: context,
                initialDate: widget.date,
                lastDate: date.add(const Duration(days: 30)),
                firstDate: date.subtract(const Duration(days: 30)))
            .then((value) {
          if (value != null) {
            widget.date = DateTime(value.year, value.month, value.day,
                widget.date.hour, widget.date.minute, 0, 0, 0);
            setState(() {
              text =
                  DateFormat("EEEE, d MMMM y", getLocale()).format(widget.date);
            });
          }
        });
      },
    );
  }
}
