import 'package:ezstudies/search/search_cell_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../agenda/agenda_cell.dart';
import '../agenda/agenda_cell_data.dart';
import '../utils/secret.dart';
import '../utils/templates.dart';
import '../utils/timestamp_utils.dart';

class SearchAgenda extends StatefulWidget {
  const SearchAgenda(this.data, {Key? key}) : super(key: key);
  final SearchCellData data;

  @override
  State<SearchAgenda> createState() => _SearchAgendaState();
}

class _SearchAgendaState extends State<SearchAgenda> {
  bool initialized = false;
  List<AgendaCellData> list = [];

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      initialized = true;
      load();
    }
    list.removeWhere((element) => element.trashed == 1);
    list.sort((a, b) => a.start.compareTo(b.start));

    Widget menu = MenuTemplate(<PopupMenuItem<String>>[
      PopupMenuItem<String>(
          value: "help", child: Text(AppLocalizations.of(context)!.help))
    ], (value) {
      switch (value) {
        case "help":
          showDialog(
            context: context,
            builder: (context) => AlertDialogTemplate(
                AppLocalizations.of(context)!.help, "help", [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.ok))
            ]),
          );
          break;
      }
    });

    Widget content = Center(
        child: TextButton(
            onPressed: () => refresh(),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: const Icon(Icons.refresh, size: 16),
              ),
              Text(AppLocalizations.of(context)!.refresh)
            ])));
    if (list.isNotEmpty) {
      content = ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: list.length,
          itemBuilder: (context, index) {
            var data = list[index];
            return AgendaCell(
                data,
                index == 0 || !isSameDay(data.start, list[index - 1].start),
                index == 0 || !isSameMonth(data.start, list[index - 1].start),
                () => {});
          });
    }

    Widget child = RefreshIndicator(onRefresh: () => refresh(), child: content);

    return Template(widget.data.name, child, menu, true);
  }

  void load() {
    SecretLoader().load().then((value) {
      String url = value.serverUrl;
      SharedPreferences.getInstance().then((value) {
        String name = value.getString("name") ?? "";
        String password = value.getString("password") ?? "";
        http.post(Uri.parse(url), body: <String, String>{
          "request": "cyu",
          "name": name,
          "password": password,
          "id": widget.data.id
        }).then((value) {
          print(value.body);
        });
      });
    });
  }

  Future<void> refresh() async {
    load();
  }
}
