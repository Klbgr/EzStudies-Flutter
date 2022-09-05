import 'package:ezstudies/homeworks/homeworks_details.dart';
import 'package:ezstudies/utils/database_helper.dart';
import 'package:ezstudies/utils/templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../utils/notifications.dart';
import '../utils/preferences.dart';
import '../utils/style.dart';
import '../utils/timestamp_utils.dart';
import 'homeworks_cell_data.dart';

class Homeworks extends StatefulWidget {
  const Homeworks({Key? key}) : super(key: key);

  @override
  State<Homeworks> createState() => _HomeworksState();
}

class _HomeworksState extends State<Homeworks> {
  List<HomeworksCellData> list = [];
  ItemScrollController itemScrollController = ItemScrollController();
  bool initialized = false;

  @override
  Widget build(BuildContext context) {
    if (!(Preferences.sharedPreferences.getBool("help_homeworks") ?? false)) {
      Preferences.sharedPreferences.setBool("help_homeworks", true).then(
          (value) => showDialog(
              context: context,
              builder: (context) => AlertDialogTemplate(
                      AppLocalizations.of(context)!.help,
                      AppLocalizations.of(context)!.help_homeworks, [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.ok,
                            style: TextStyle(color: Style.primary)))
                  ])));
    }

    if (!initialized) {
      initialized = true;
      load();
    }
    list.sort((a, b) => a.date.compareTo(b.date));

    Widget menu = MenuTemplate(<PopupMenuItem<String>>[
      PopupMenuItem<String>(
          value: "help",
          child: Text(AppLocalizations.of(context)!.help,
              style: TextStyle(color: Style.text)))
    ], (value) {
      switch (value) {
        case "help":
          showDialog(
              context: context,
              builder: (context) => AlertDialogTemplate(
                      AppLocalizations.of(context)!.help,
                      AppLocalizations.of(context)!.help_homeworks, [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.ok,
                            style: TextStyle(color: Style.primary)))
                  ]));
          break;
      }
    });

    Widget child =
        Center(child: Text(AppLocalizations.of(context)!.nothing_to_show));

    Column buttons =
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      OpenContainerTemplate(
          FloatingActionButton.extended(
              elevation: 0,
              onPressed: null,
              backgroundColor: Style.primary,
              label: Text(AppLocalizations.of(context)!.add,
                  style: TextStyle(color: Style.text)),
              icon: Icon(Icons.add, color: Style.text)),
          const HomeworksDetails(add: true),
          onClosed: () => load(),
          radius: const BorderRadius.all(Radius.circular(24)),
          elevation: 6,
          color: Style.primary,
          trigger: (_) {})
    ]);

    if (list.isNotEmpty) {
      child = ScrollablePositionedList.builder(
        itemCount: list.length,
        itemBuilder: (context, index) => Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) {
            remove(list[index]);
          },
          background: Container(
              color: Colors.red,
              child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.delete, color: Style.text),
                        Icon(Icons.delete, color: Style.text)
                      ]))),
          child: _HomeworksCell(list[index],
              onClosed: () => load(), onChanged: () => scheduleNotifications()),
        ),
        itemScrollController: itemScrollController,
      );

      buttons.children.add(Container(
          margin: const EdgeInsets.only(top: 10),
          child: FloatingActionButton.extended(
              onPressed: () => scrollToToday(),
              label: Text(AppLocalizations.of(context)!.scroll_to_today,
                  style: TextStyle(color: Style.text)),
              icon: Icon(Icons.today, color: Style.text))));
    }

    child = Stack(
        children: [child, Positioned(bottom: 20, right: 20, child: buttons)]);

    return Template(AppLocalizations.of(context)!.homeworks, child, menu: menu);
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    Future.delayed(const Duration(milliseconds: 300))
        .then((value) => scrollToToday());
  }

  void remove(HomeworksCellData data) {
    DatabaseHelper database = DatabaseHelper();
    database.open().then((_) => database
        .deleteHomeworks(data)
        .then((_) => database.close().then((_) => setState(() {
              scheduleNotifications();
              list.remove(data);
            }))));
  }

  void load() {
    DatabaseHelper database = DatabaseHelper();
    database.open().then((_) => database
        .getHomeworks()
        .then((value) => database.close().then((_) => setState(() {
              scheduleNotifications();
              list = value;
            }))));
  }

  void scrollToToday() {
    if (list.isNotEmpty) {
      int now = DateTime.now().millisecondsSinceEpoch;
      int index = 0;
      if (now > list[0].date) {
        while (index < list.length &&
            !(isSameDay(list[index].date, now) || list[index].date >= now)) {
          index++;
        }
      }
      itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    }
  }

  void scheduleNotifications() {
    if (Preferences.sharedPreferences.getBool("notifications_homeworks") ??
        true) {
      Notifications.cancelNotificationsHomeworks().then(
          (value) => Notifications.scheduleNotificationsHomeworks(context));
    }
  }
}

class _HomeworksCell extends StatefulWidget {
  const _HomeworksCell(this.data,
      {required this.onClosed, required this.onChanged, Key? key})
      : super(key: key);
  final HomeworksCellData data;
  final Function onClosed;
  final Function onChanged;

  @override
  State<_HomeworksCell> createState() => _HomeworksCellState();
}

class _HomeworksCellState extends State<_HomeworksCell> {
  late HomeworksCellData newData = HomeworksCellData(
      id: widget.data.id,
      description: widget.data.description,
      date: widget.data.date,
      done: widget.data.done);

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(getLocale(), null);

    Widget child = Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: widget.data.getColor(),
            borderRadius: const BorderRadius.all(Radius.circular(16))),
        child: Column(children: [
          Container(
              alignment: Alignment.centerLeft,
              child: Text(widget.data.description,
                  style: TextStyle(color: Style.text))),
          Container(
              alignment: Alignment.centerLeft,
              child: Text(
                  DateFormat("EEEE, d MMMM y - HH:mm", getLocale()).format(
                      DateTime.fromMillisecondsSinceEpoch(widget.data.date)),
                  style: TextStyle(color: Style.text)))
        ]));

    return Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
        child: Row(
          children: [
            Container(
                margin: const EdgeInsets.only(right: 20),
                child: Checkbox(
                  checkColor: Style.background,
                  value: (newData.done == 1) ? true : false,
                  onChanged: (value) {
                    setState(() =>
                        (value == true) ? newData.done = 1 : newData.done = 0);
                    DatabaseHelper database = DatabaseHelper();
                    database.open().then((_) => database
                        .insertOrReplaceHomeworks(newData)
                        .then((_) =>
                            database.close().then((_) => widget.onChanged())));
                  },
                )),
            Expanded(
                child: OpenContainerTemplate(
                    child, HomeworksDetails(data: widget.data),
                    onClosed: () => widget.onClosed(),
                    trigger: (_) {},
                    radius: const BorderRadius.all(Radius.circular(16)),
                    color: widget.data.getColor()))
          ],
        ));
  }
}
