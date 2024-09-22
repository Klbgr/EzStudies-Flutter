import 'dart:convert';

import 'package:ezstudies/agenda/agenda_details.dart';
import 'package:ezstudies/agenda/agenda_view_model.dart';
import 'package:ezstudies/agenda/agenda_week_view.dart';
import 'package:ezstudies/search/search_cell_data.dart';
import 'package:ezstudies/utils/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stacked/stacked.dart';

import '../config/env.dart';
import '../utils/notifications.dart';
import '../utils/preferences.dart';
import '../utils/templates.dart';
import '../utils/timestamp_utils.dart';
import 'agenda_cell.dart';
import 'agenda_cell_data.dart';

class Agenda extends StatefulWidget {
  const Agenda(
      {this.agenda = false,
      this.trash = false,
      this.search = false,
      this.data,
      this.onClosed,
      this.agendaViewModel,
      super.key});

  final bool agenda;
  final bool trash;
  final bool search;
  final SearchCellData? data;
  final Function? onClosed;
  final AgendaViewModel? agendaViewModel;

  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  List<AgendaCellData> list = [];
  ItemScrollController itemScrollController = ItemScrollController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    list.sort((a, b) => a.start.compareTo(b.start));

    Widget menu = MenuTemplate(
        items: [
          if (widget.agenda || widget.search)
            PopupMenuItem<String>(
                value: "week_view",
                child: Text(
                  AppLocalizations.of(context)!.week_view,
                )),
          if (widget.agenda && !kIsWeb)
            PopupMenuItem<String>(
                value: "trash",
                child: Text(
                  AppLocalizations.of(context)!.trash,
                )),
          if (widget.agenda && !kIsWeb)
            PopupMenuItem<String>(
                value: "reset",
                child: Text(
                  AppLocalizations.of(context)!.reset,
                )),
          if (widget.agenda)
            PopupMenuItem<String>(
                value: "help_agenda",
                child: Text(
                  AppLocalizations.of(context)!.help,
                )),
          if (widget.trash)
            PopupMenuItem(
                value: "help_trash",
                child: Text(
                  AppLocalizations.of(context)!.help,
                )),
          if (widget.search)
            PopupMenuItem<String>(
                value: "help_search",
                child: Text(
                  AppLocalizations.of(context)!.help,
                ))
        ],
        onSelected: (value) {
          switch (value) {
            case "help_agenda":
              showDialog(
                context: context,
                builder: (context) => AlertDialogTemplate(
                    title: AppLocalizations.of(context)!.help,
                    content: AppLocalizations.of(context)!.help_agenda,
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalizations.of(context)!.ok,
                          )),
                    ]),
              );
              break;
            case "trash":
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Agenda(trash: true, onClosed: () => load())));
              break;
            case "week_view":
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AgendaWeekView(data: list)));
              break;
            case "reset":
              showDialog(
                context: context,
                builder: (context) => AlertDialogTemplate(
                    title: AppLocalizations.of(context)!.reset,
                    content: AppLocalizations.of(context)!.reset_desc,
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                          )),
                      TextButton(
                          onPressed: () {
                            reset();
                            Navigator.pop(context);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.reset,
                          ))
                    ]),
              );
              break;
            case "help_trash":
              showDialog(
                  context: context,
                  builder: (context) => AlertDialogTemplate(
                          title: AppLocalizations.of(context)!.help,
                          content: AppLocalizations.of(context)!.help_trash,
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  AppLocalizations.of(context)!.ok,
                                ))
                          ]));
              break;
            case "help_search":
              showDialog(
                context: context,
                builder: (context) => AlertDialogTemplate(
                    title: AppLocalizations.of(context)!.help,
                    content: AppLocalizations.of(context)!.help_search_agenda,
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalizations.of(context)!.ok,
                          )),
                    ]),
              );
              break;
          }
        });

    Widget content = list.isEmpty
        ? Center(
            child: widget.trash
                ? Text(AppLocalizations.of(context)!.nothing_to_show)
                : TextButton(
                    onPressed: () => refresh(),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: const Icon(Icons.refresh, size: 16),
                          ),
                          Text(AppLocalizations.of(context)!.refresh)
                        ])))
        : ScrollablePositionedList.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemScrollController: itemScrollController,
            scrollDirection: Axis.vertical,
            itemCount: list.length,
            itemBuilder: (context, index) {
              var data = list[index];
              Widget cell = AgendaCell(
                  data: data,
                  firstOfDay: index == 0 ||
                      !isSameDay(data.start, list[index - 1].start),
                  firstOfMonth: index == 0 ||
                      !isSameMonth(data.start, list[index - 1].start),
                  onClosed: () {
                    if (widget.agenda) {
                      load(showLoading: false);
                    }
                  },
                  editable: widget.agenda,
                  search: widget.search);
              return widget.search || kIsWeb
                  ? cell
                  : Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        remove(data);
                      },
                      background: Container(
                          color: widget.agenda ? Colors.red : Colors.green,
                          child: Container(
                              margin: const EdgeInsets.only(left: 20),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      widget.agenda
                                          ? Icons.delete
                                          : Icons.restore_from_trash,
                                    )
                                  ]))),
                      secondaryBackground: Container(
                          color: widget.agenda ? Colors.red : Colors.green,
                          child: Container(
                              margin: const EdgeInsets.only(right: 20),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      widget.agenda
                                          ? Icons.delete
                                          : Icons.restore_from_trash,
                                    )
                                  ]))),
                      child: cell,
                    );
            },
          );

    Widget child = Stack(children: [
      widget.trash
          ? content
          : RefreshIndicator(
              onRefresh: () => refresh(),
              // backgroundColor: Style.background,
              child: content),
      Positioned(
          bottom: 20,
          right: 20,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (list.isNotEmpty && !widget.trash)
              FloatingActionButton(
                  tooltip: AppLocalizations.of(context)!.scroll_to_today,
                  onPressed: () => scrollToToday(),
                  heroTag: "today",
                  child: const Icon(Icons.today)),
            if (!kIsWeb && widget.agenda)
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: FloatingActionButton(
                  tooltip: AppLocalizations.of(context)!.add,
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AgendaDetails(
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

    if (widget.agenda &&
        !(Preferences.sharedPreferences.getBool(Preferences.helpAgenda) ??
            false)) {
      Preferences.sharedPreferences.setBool(Preferences.helpAgenda, true).then(
          (value) => showDialog(
              context: context,
              builder: (context) => AlertDialogTemplate(
                      title: AppLocalizations.of(context)!.help,
                      content: AppLocalizations.of(context)!.help_agenda,
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppLocalizations.of(context)!.ok,
                            ))
                      ])));
    } else if (widget.trash &&
        !(Preferences.sharedPreferences.getBool(Preferences.helpTrash) ??
            false)) {
      Preferences.sharedPreferences.setBool(Preferences.helpTrash, true).then(
          (value) => showDialog(
              context: context,
              builder: (context) => AlertDialogTemplate(
                      title: AppLocalizations.of(context)!.help,
                      content: AppLocalizations.of(context)!.help_trash,
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppLocalizations.of(context)!.ok,
                            ))
                      ])));
    } else if (widget.search &&
        !(Preferences.sharedPreferences.getBool(Preferences.helpSearchAgenda) ??
            false)) {
      Preferences.sharedPreferences
          .setBool(Preferences.helpSearchAgenda, true)
          .then((value) => showDialog(
              context: context,
              builder: (context) => AlertDialogTemplate(
                      title: AppLocalizations.of(context)!.help,
                      content: AppLocalizations.of(context)!.help_search_agenda,
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppLocalizations.of(context)!.ok,
                            ))
                      ])));
    }

    String title = "";
    if (widget.agenda) {
      title = AppLocalizations.of(context)!.agenda;
    } else if (widget.trash) {
      title = AppLocalizations.of(context)!.trash;
    } else if (widget.search) {
      title = widget.data!.name;
    }
    Template template =
        Template(title: title, menu: menu, back: !widget.agenda, child: child);
    return widget.agenda
        ? ViewModelBuilder<AgendaViewModel>.nonReactive(
            disposeViewModel: false,
            viewModelBuilder: () => widget.agendaViewModel!,
            builder: (context, model, child) => template)
        : template;
  }

  @override
  void setState(VoidCallback fn, {bool scroll = false}) {
    if (mounted) {
      super.setState(fn);
      if (scroll) {
        Future.delayed(const Duration(milliseconds: 300))
            .then((value) => scrollToToday());
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.onClosed != null) {
      Future.delayed(const Duration(), () => widget.onClosed!());
    }
  }

  void scrollToToday() {
    if (list.isNotEmpty) {
      int now = DateTime.now().millisecondsSinceEpoch;
      int index = 0;
      if (now > list[0].start) {
        while (index < list.length &&
            !(isSameDay(list[index].start, now) || list[index].start >= now)) {
          index++;
        }
      }
      if (itemScrollController.isAttached) {
        itemScrollController.scrollTo(
            index: index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    }
  }

  Future<void> load(
      {bool scroll = false, bool showLoading = true, bool force = true}) async {
    if (showLoading) {
      setState(() => loading = true);
    }
    if (widget.agenda) {
      if (widget.agendaViewModel!.initialized && !force) {
        setState(() {
          list = widget.agendaViewModel!.list;
          loading = false;
        }, scroll: scroll);
      } else {
        String url = "${Secret.server_url}api/index.php";
        String name =
            Preferences.sharedPreferences.getString(Preferences.name) ?? "";
        String password =
            Preferences.sharedPreferences.getString(Preferences.password) ?? "";
        http.Response response = await http.post(Uri.parse(url),
            body: <String, String>{
              "request": "cyu",
              "name": name,
              "password": password
            }).catchError((_) => http.Response("", 404));
        if (response.statusCode == 200 && response.body.isNotEmpty) {
          if (kIsWeb) {
            setState(() {
              list = processJson(response.body);
              widget.agendaViewModel!.list = list;
              widget.agendaViewModel!.initialized = true;
              loading = false;
            }, scroll: scroll);
          } else {
            DatabaseHelper database = DatabaseHelper();
            await database.open();
            await database.insertAll(processJson(response.body));
            list = await database.getAgenda(DatabaseHelper.agenda);
            await database.close();
            setState(() {
              scheduleNotifications();
              list.removeWhere((element) => element.trashed == 1);
              widget.agendaViewModel!.list = list;
              widget.agendaViewModel!.initialized = true;
              loading = false;
            }, scroll: scroll);
          }
        } else {
          DatabaseHelper database = DatabaseHelper();
          await database.open();
          list = await database.getAgenda(DatabaseHelper.agenda);
          await database.close();
          setState(() {
            list.removeWhere((element) => element.trashed == 1);
            widget.agendaViewModel!.list = list;
            widget.agendaViewModel!.initialized = true;
            loading = false;
          }, scroll: scroll);
          showDialog(
            context: context,
            builder: (context) => AlertDialogTemplate(
                title: AppLocalizations.of(context)!.error,
                content: AppLocalizations.of(context)!.error_internet,
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.ok))
                ]),
          );
        }
      }
    } else if (widget.trash) {
      DatabaseHelper database = DatabaseHelper();
      await database.open();
      list = await database.getAgenda(DatabaseHelper.agenda);
      await database.close();
      setState(() {
        list.removeWhere((element) => element.trashed == 0);
        loading = false;
      }, scroll: scroll);
    } else if (widget.search) {
      String url = "${Secret.server_url}api/index.php";
      String name =
          Preferences.sharedPreferences.getString(Preferences.name) ?? "";
      String password =
          Preferences.sharedPreferences.getString(Preferences.password) ?? "";
      http.Response response = await http.post(Uri.parse(url),
          body: <String, String>{
            "request": "cyu",
            "name": name,
            "password": password,
            "id": widget.data!.id
          }).catchError((_) => http.Response("", 404));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        setState(() {
          list = processJson(response.body);
          loading = false;
        }, scroll: scroll);
      } else {
        setState(() => loading = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialogTemplate(
              title: AppLocalizations.of(context)!.error,
              content: AppLocalizations.of(context)!.error_internet,
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.ok))
              ]),
        );
      }
    }
  }

  Future<void> remove(AgendaCellData data) async {
    if (widget.agenda) {
      data.trashed = 1;
      DatabaseHelper database = DatabaseHelper();
      await database.open();
      await database.insertOrReplaceAgenda(DatabaseHelper.agenda, data);
      await database.close();
      setState(() {
        scheduleNotifications();
        list.remove(data);
      });
    } else if (widget.trash) {
      data.trashed = 0;
      DatabaseHelper database = DatabaseHelper();
      await database.open();
      await database.insertOrReplaceAgenda(DatabaseHelper.agenda, data);
      await database.close();
      setState(() => list.remove(data));
    }
  }

  Future<void> reset() async {
    DatabaseHelper database = DatabaseHelper();
    await database.open();
    await database.reset();
    await database.close();
    load();
  }

  void scheduleNotifications() {
    if (Preferences.sharedPreferences.getBool(Preferences.notifications) ??
        true) {
      Notifications.cancelNotificationsAgenda()
          .then((_) => Notifications.scheduleNotificationsAgenda(context));
    }
  }

  List<AgendaCellData> processJson(String json) {
    List<AgendaCellData> list = [];
    if (json.isNotEmpty) {
      List<dynamic> data = jsonDecode(json) ?? [];
      for (int i = 0; i < data.length; i++) {
        try {
          var item = data[i];
          List<String> start = item["start"].toString().split("T");
          List<int> startDate =
              start[0].split("-").map((element) => int.parse(element)).toList();
          List<int> startTime =
              start[1].split(":").map((element) => int.parse(element)).toList();
          DateTime startDateTime = DateTime(startDate[0], startDate[1],
              startDate[2], startTime[0], startTime[1], startTime[2], 0, 0);
          int startTimestamp = startDateTime.millisecondsSinceEpoch;
          int endTimestamp = 0;
          if (item["end"].toString() != "null") {
            List<String> end = item["end"].toString().split("T");
            List<int> endDate =
                end[0].split("-").map((element) => int.parse(element)).toList();
            List<int> endTime =
                end[1].split(":").map((element) => int.parse(element)).toList();
            endTimestamp = DateTime(endDate[0], endDate[1], endDate[2],
                    endTime[0], endTime[1], endTime[2], 0, 0)
                .millisecondsSinceEpoch;
          } else {
            endTimestamp = startDateTime
                .add(Duration(hours: 21 - startTime[0]))
                .millisecondsSinceEpoch;
          }

          String description = item["description"]
              .toString()
              .replaceAll("\n", "")
              .replaceAll("\r", "")
              .replaceAll("<br />", "\n");
          description = HtmlUnescape().convert(description);
          list.add(AgendaCellData(
              id: item["id"],
              description: description,
              start: startTimestamp,
              end: endTimestamp,
              added: 0,
              trashed: 0,
              edited: 0));
        } catch (_) {}
      }
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    load(scroll: true, force: false);
  }

  Future<void> refresh() async {
    await load();
  }
}
