import 'package:ezstudies/agenda/details.dart';
import 'package:ezstudies/search/search_cell_data.dart';
import 'package:ezstudies/utils/database_helper.dart';
import 'package:ezstudies/utils/secret.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import '../utils/preferences.dart';
import '../utils/style.dart';
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
      Key? key})
      : super(key: key);
  final bool agenda;
  final bool trash;
  final bool search;
  final SearchCellData? data;

  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  bool initialized = false;
  List<AgendaCellData> list = [];
  bool pop = true;

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      initialized = true;
      load();
    }
    list.sort((a, b) => a.start.compareTo(b.start));

    Widget content = Center(
        child: widget.trash
            ? Text(AppLocalizations.of(context)!.nothing_to_show,
                style: TextStyle(color: Style.text))
            : TextButton(
                onPressed: () => refresh(),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child:
                            Icon(Icons.refresh, size: 16, color: Style.primary),
                      ),
                      Text(AppLocalizations.of(context)!.refresh,
                          style: TextStyle(color: Style.primary))
                    ])));

    if (list.isNotEmpty) {
      content = ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: list.length,
        itemBuilder: (context, index) {
          var data = list[index];
          Widget cell = AgendaCell(
              data,
              index == 0 || !isSameDay(data.start, list[index - 1].start),
              index == 0 || !isSameMonth(data.start, list[index - 1].start),
              onClosed: () => load(),
              editable: widget.agenda);
          return widget.search
              ? cell
              : Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    remove(data);
                  },
                  background: Container(
                      color: widget.agenda ? Colors.red : Colors.green,
                      child: Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                    widget.agenda
                                        ? Icons.delete
                                        : Icons.restore_from_trash,
                                    color: Style.text),
                                Icon(
                                    widget.agenda
                                        ? Icons.delete
                                        : Icons.restore_from_trash,
                                    color: Style.text)
                              ]))),
                  child: cell,
                );
        },
      );
    }

    Widget child = widget.trash
        ? content
        : RefreshIndicator(
            onRefresh: () => refresh(),
            backgroundColor: Style.background,
            child: content);
    Widget? menu;
    if (widget.agenda) {
      OpenContainerTemplate add = OpenContainerTemplate(
          FloatingActionButton.extended(
              heroTag: "add",
              elevation: 0,
              onPressed: null,
              backgroundColor: Style.primary,
              label: Text(AppLocalizations.of(context)!.add,
                  style: TextStyle(color: Style.text)),
              icon: Icon(Icons.add, color: Style.text)),
          Details(add: true),
          () => load(),
          radius: const BorderRadius.all(Radius.circular(24)),
          elevation: 6,
          color: Style.primary,
          trigger: (_) {});
      child = Stack(
        children: [child, Positioned(right: 20, bottom: 20, child: add)],
      );

      Function trashTrigger = () {};

      OpenContainerTemplate trash = OpenContainerTemplate(
          Text(AppLocalizations.of(context)!.trash,
              style: TextStyle(fontSize: 16, color: Style.text)),
          const Agenda(trash: true), () {
        if (pop) {
          Navigator.pop(context);
        }
        pop = true;
        load();
      }, color: Colors.transparent, trigger: (value) => trashTrigger = value);

      menu = MenuTemplate(<PopupMenuItem<String>>[
        PopupMenuItem<String>(value: "trash", child: trash),
        PopupMenuItem<String>(
            value: "reset",
            child: Text(AppLocalizations.of(context)!.reset,
                style: TextStyle(color: Style.text))),
        PopupMenuItem<String>(
            value: "help",
            child: Text(AppLocalizations.of(context)!.help,
                style: TextStyle(color: Style.text)))
      ], (value) {
        switch (value) {
          case "trash":
            pop = false;
            trashTrigger.call();
            break;
          case "reset":
            showDialog(
              context: context,
              builder: (context) => AlertDialogTemplate(
                  AppLocalizations.of(context)!.reset, "reset?", [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.cancel,
                        style: TextStyle(color: Style.primary))),
                TextButton(
                    onPressed: () {
                      reset();
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.reset,
                        style: TextStyle(color: Style.primary)))
              ]),
            );
            break;
          case "help":
            showDialog(
              context: context,
              builder: (context) => AlertDialogTemplate(
                  AppLocalizations.of(context)!.help, "help", [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.ok,
                        style: TextStyle(color: Style.primary))),
              ]),
            );
            break;
        }
      });
    } else if (widget.trash) {
      menu = MenuTemplate(<PopupMenuItem<String>>[
        PopupMenuItem(
            value: "help",
            child: Text(AppLocalizations.of(context)!.help,
                style: TextStyle(color: Style.text)))
      ], (value) {
        switch (value) {
          case "help":
            showDialog(
                context: context,
                builder: (context) => AlertDialogTemplate(
                        AppLocalizations.of(context)!.help, "help?", [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)!.ok,
                              style: TextStyle(color: Style.primary)))
                    ]));
            break;
        }
      });
    } else if (widget.search) {
      menu = MenuTemplate(<PopupMenuItem<String>>[
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
                  AppLocalizations.of(context)!.help, "help", [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.ok,
                        style: TextStyle(color: Style.primary))),
              ]),
            );
            break;
        }
      });
    }

    String title = "";
    if (widget.agenda) {
      title = AppLocalizations.of(context)!.agenda;
    } else if (widget.trash) {
      title = AppLocalizations.of(context)!.trash;
    } else if (widget.search) {
      title = widget.data!.name;
    }

    return Template(title, child, menu: menu, back: !widget.agenda);
  }

  void load() {
    if (widget.agenda || widget.trash) {
      int trash = 1;
      if (widget.trash) {
        trash = 0;
      }
      DatabaseHelper database = DatabaseHelper();
      database
          .open()
          .then((value) => database.get(DatabaseHelper.agenda).then((value) {
                setState(() {
                  list = value;
                  list.removeWhere((element) => element.trashed == trash);
                });
                database.close();
              }));
    } else if (widget.search) {
      String url = Secret.serverUrl;
      String name = Preferences.sharedPreferences.getString("name") ?? "";
      String password =
          Preferences.sharedPreferences.getString("password") ?? "";
      http.post(Uri.parse(url), body: <String, String>{
        "request": "cyu",
        "name": name,
        "password": password,
        "id": widget.data!.id
      }).then((value) {
        print(value.body);
      });
    }
  }

  void remove(AgendaCellData data) {
    if (widget.agenda) {
      data.trashed = 1;
      DatabaseHelper database = DatabaseHelper();
      database.open().then((value) => database
          .insertOrReplace(DatabaseHelper.agenda, data)
          .then((value) => database.close()));
      setState(() => list.remove(data));
    } else if (widget.trash) {
      data.trashed = 0;
      DatabaseHelper database = DatabaseHelper();
      database.open().then((value) => database
          .insertOrReplace(DatabaseHelper.agenda, data)
          .then((value) => database.close()));
      setState(() => list.remove(data));
    }
  }

  void reset() {
    DatabaseHelper database = DatabaseHelper();
    database.open().then((value) => database
        .reset()
        .then((value) => database.close().then((value) => load())));
  }

  Future<void> refresh() async {
    load();
  }
}
