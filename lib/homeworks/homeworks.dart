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
import '../utils/timestamp_utils.dart';
import 'homeworks_cell_data.dart';

class Homeworks extends StatefulWidget {
  const Homeworks({super.key});

  @override
  State<Homeworks> createState() => _HomeworksState();
}

class _HomeworksState extends State<Homeworks> {
  List<HomeworksCellData> list = [];
  ItemScrollController itemScrollController = ItemScrollController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (!(Preferences.sharedPreferences.getBool(Preferences.helpHomeworks) ??
        false)) {
      Preferences.sharedPreferences
          .setBool(Preferences.helpHomeworks, true)
          .then((value) => showDialog(
              context: context,
              builder: (context) => AlertDialogTemplate(
                      title: AppLocalizations.of(context)!.help,
                      content: AppLocalizations.of(context)!.help_homeworks,
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppLocalizations.of(context)!.ok,
                            ))
                      ])));
    }

    list.sort((a, b) => a.date.compareTo(b.date));

    Widget menu = MenuTemplate(
        items: <PopupMenuItem<String>>[
          PopupMenuItem<String>(
              value: "help",
              child: Text(
                AppLocalizations.of(context)!.help,
              ))
        ],
        onSelected: (value) {
          switch (value) {
            case "help":
              showDialog(
                  context: context,
                  builder: (context) => AlertDialogTemplate(
                          title: AppLocalizations.of(context)!.help,
                          content: AppLocalizations.of(context)!.help_homeworks,
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  AppLocalizations.of(context)!.ok,
                                ))
                          ]));
              break;
          }
        });

    Widget child = Stack(children: [
      list.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.nothing_to_show))
          : ScrollablePositionedList.builder(
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
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    )),
                secondaryBackground: Container(
                    color: Colors.red,
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    )),
                child: _HomeworksCell(list[index],
                    onClosed: () => load(),
                    onChanged: () => scheduleNotifications()),
              ),
              itemScrollController: itemScrollController,
            ),
      Positioned(
          bottom: 20,
          right: 20,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (list.isNotEmpty)
              FloatingActionButton(
                onPressed: () => scrollToToday(),
                tooltip: AppLocalizations.of(context)!.scroll_to_today,
                heroTag: "today",
                child: const Icon(Icons.today),
              ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: FloatingActionButton(
                tooltip: AppLocalizations.of(context)!.add,
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomeworksDetails(
                              add: true,
                            ))).then((_) => load()),
                heroTag: "add",
                child: const Icon(Icons.add),
              ),
            )
          ])),
      if (loading)
        Container(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            alignment: Alignment.center,
            child: const CircularProgressIndicator())
    ]);

    return Template(
        title: AppLocalizations.of(context)!.homeworks,
        menu: menu,
        child: child);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
      Future.delayed(const Duration(milliseconds: 300))
          .then((value) => scrollToToday());
    }
  }

  Future<void> remove(HomeworksCellData data) async {
    DatabaseHelper database = DatabaseHelper();
    await database.open();
    await database.deleteHomeworks(data);
    await database.close();
    setState(() {
      scheduleNotifications();
      list.remove(data);
    });
  }

  Future<void> load() async {
    setState(() => loading = true);
    DatabaseHelper database = DatabaseHelper();
    await database.open();
    list = await database.getHomeworks();
    await database.close();
    setState(() {
      scheduleNotifications();
      loading = false;
    });
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
      if (itemScrollController.isAttached) {
        itemScrollController.scrollTo(
            index: index,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.ease);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  void scheduleNotifications() {
    if (Preferences.sharedPreferences
            .getBool(Preferences.notificationsHomeworks) ??
        true) {
      Notifications.cancelNotificationsHomeworks().then(
          (value) => Notifications.scheduleNotificationsHomeworks(context));
    }
  }
}

class _HomeworksCell extends StatefulWidget {
  const _HomeworksCell(this.data,
      {required this.onClosed, required this.onChanged});

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
              child: Text(
                widget.data.description,
              )),
          Container(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat("EEEE, d MMMM y - HH:mm", getLocale()).format(
                    DateTime.fromMillisecondsSinceEpoch(widget.data.date)),
              ))
        ]));

    return Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
        child: Row(
          children: [
            Container(
                margin: const EdgeInsets.only(right: 20),
                child: Checkbox(
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
                    child1: child,
                    child2: HomeworksDetails(data: widget.data),
                    onClosed: () => widget.onClosed(),
                    radius: const BorderRadius.all(Radius.circular(16)),
                    color: widget.data.getColor()))
          ],
        ));
  }
}
