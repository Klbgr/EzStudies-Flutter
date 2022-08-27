import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../utils/style.dart';
import '../utils/timestamp_utils.dart';

class DateInput extends StatefulWidget {
  DateInput(this.label, this.icon, this.date, {this.editable = true, Key? key})
      : super(key: key);
  final String label;
  final IconData icon;
  DateTime date;
  final bool editable;

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
