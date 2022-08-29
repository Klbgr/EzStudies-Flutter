import 'package:animations/animations.dart';
import 'package:ezstudies/utils/style.dart';
import 'package:ezstudies/utils/timestamp_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Template extends StatelessWidget {
  const Template(this.title, this.child,
      {this.menu, this.back = false, Key? key})
      : super(key: key);
  final String title;
  final Widget child;
  final Widget? menu;
  final bool back;

  @override
  Widget build(BuildContext context) {
    IconButton? iconButton;
    if (back) {
      iconButton = IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Style.text,
        ),
        onPressed: () => Navigator.pop(context),
      );
    }
    return Scaffold(
        backgroundColor: Style.background,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  (Style.theme == 0) ? Brightness.dark : Brightness.light,
              statusBarBrightness:
                  (Style.theme == 0) ? Brightness.light : Brightness.dark),
          actions: (menu == null) ? null : [menu!],
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: iconButton,
        ),
        body: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 20, bottom: 20),
              child: Text(
                title,
                style: TextStyle(fontSize: 30, color: Style.text),
              ),
            ),
            Expanded(
              child: child,
            )
          ],
        ));
  }
}

class MenuTemplate extends StatelessWidget {
  const MenuTemplate(this.items, this.onSelected, {Key? key}) : super(key: key);
  final List<PopupMenuItem<String>> items;
  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Style.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      icon: Icon(Icons.more_vert_rounded, color: Style.text),
      itemBuilder: (BuildContext context) {
        return items;
      },
      onSelected: (value) {
        onSelected(value);
      },
    );
  }
}

class OpenContainerTemplate extends StatelessWidget {
  const OpenContainerTemplate(this.child1, this.child2, this.onClosed,
      {this.color,
      this.radius = BorderRadius.zero,
      this.elevation = 0,
      required this.trigger,
      Key? key})
      : super(key: key);
  final Widget child1;
  final Widget child2;
  final Function onClosed;
  final Function(Function) trigger;
  final Color? color;
  final BorderRadiusGeometry radius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedShape: RoundedRectangleBorder(borderRadius: radius),
      closedColor: (color == null) ? Style.background : color!,
      openColor: Style.background,
      closedElevation: elevation,
      transitionType: ContainerTransitionType.fadeThrough,
      closedBuilder: (context, action) {
        trigger(action);
        return child1;
      },
      openBuilder: (context, action) => child2,
      onClosed: (_) => onClosed(),
    );
  }
}

class AlertDialogTemplate extends StatelessWidget {
  const AlertDialogTemplate(this.title, this.content, this.actions, {Key? key})
      : super(key: key);
  final String title;
  final String content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        backgroundColor: Style.background,
        title: Text(title, style: TextStyle(color: Style.text)),
        content: Text(content, style: TextStyle(color: Style.text)),
        actions: actions);
  }
}

class TextFormFieldTemplate extends StatefulWidget {
  const TextFormFieldTemplate(this.label, this.icon,
      {this.enabled = true,
      this.initialValue,
      this.onChanged,
      this.onTapped,
      this.date = false,
      this.time = false,
      this.dateTime,
      this.hidden = false,
      Key? key})
      : super(key: key);
  final String label;
  final IconData icon;
  final String? initialValue;
  final bool enabled;
  final Function(String)? onChanged;
  final Function(int)? onTapped;
  final bool date;
  final bool time;
  final DateTime? dateTime;
  final bool hidden;

  @override
  State<TextFormFieldTemplate> createState() => _TextFormFieldTemplateState();
}

class _TextFormFieldTemplateState extends State<TextFormFieldTemplate> {
  late DateTime dateTime = widget.dateTime!;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.hidden,
      enabled: widget.enabled,
      readOnly: widget.date || widget.time,
      cursorColor: Style.primary,
      style: TextStyle(color: Style.text),
      decoration: InputDecoration(
        filled: true,
        fillColor: Style.secondary,
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.transparent)),
        enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.transparent)),
        disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.transparent)),
        hintText: widget.label.toLowerCase(),
        hintStyle: TextStyle(color: Style.hint),
        label: Text(widget.label, style: TextStyle(color: Style.hint)),
        icon: Icon(widget.icon, color: Style.text),
      ),
      controller: TextEditingController(
          text: !(widget.date || widget.time)
              ? widget.initialValue
              : DateFormat(
                      widget.time ? "HH:mm" : "EEEE, d MMMM y", getLocale())
                  .format(dateTime)),
      onChanged: (value) {
        if (!(widget.date && widget.time)) {
          widget.onChanged!(value);
        }
      },
      onTap: () {
        if (widget.time) {
          showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(dateTime))
              .then((value) {
            if (value != null) {
              setState(() {
                dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day,
                    value.hour, value.minute, 0, 0, 0);
              });
              widget.onTapped!(dateTime.millisecondsSinceEpoch);
            }
          });
        } else if (widget.date) {
          showDatePicker(
                  context: context,
                  initialDate: dateTime,
                  lastDate: dateTime.add(const Duration(days: 30)),
                  firstDate: dateTime.subtract(const Duration(days: 30)))
              .then((value) {
            if (value != null) {
              setState(() {
                dateTime = DateTime(value.year, value.month, value.day,
                    dateTime.hour, dateTime.minute, 0, 0, 0);
              });
              widget.onTapped!(dateTime.millisecondsSinceEpoch);
            }
          });
        }
      },
    );
  }
}
