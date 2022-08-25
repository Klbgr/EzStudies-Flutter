import 'dart:convert';

import 'package:ezstudies/search/search_agenda.dart';
import 'package:ezstudies/search/search_cell_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/secret.dart';
import '../utils/templates.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String query = "";
  List<SearchCellData> list = [];

  @override
  Widget build(BuildContext context) {
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
                  ]));
          break;
      }
    });

    Widget child = Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Flexible(
                    child: TextField(
                        autocorrect: false,
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.search),
                        onSubmitted: (value) => search(),
                        onChanged: (value) {
                          query = value;
                          if (query.length >= 3) {
                            search();
                          }
                        })),
                IconButton(
                    icon: const Icon(Icons.search), onPressed: () => search())
              ],
            ),
            Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(10),
                height: 200,
                decoration: BoxDecoration(
                    color:
                        (list.isEmpty) ? Colors.transparent : Colors.blue[50],
                    borderRadius: BorderRadius.circular(16)),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: list.length,
                  itemBuilder: (context, index) =>
                      _SearchCell(list[index], index == list.length - 1),
                ))
          ],
        ));

    return Template(AppLocalizations.of(context)!.search, child, menu, false);
  }

  void search() {
    if (query.isNotEmpty) {
      SecretLoader().load().then((value) {
        String url = value.serverUrl;
        SharedPreferences.getInstance().then((value) {
          String name = value.getString("name") ?? "";
          String password = value.getString("password") ?? "";
          http.post(Uri.parse(url), body: <String, String>{
            "request": "cyu_search",
            "name": name,
            "password": password,
            "query": query.replaceAll(" ", "+")
          }).then((value) {
            List<dynamic> results = jsonDecode(value.body)["results"];
            List<SearchCellData> newList = [];
            for (var element in results) {
              newList.add(SearchCellData(
                  id: element["id"],
                  name: element["text"],
                  dept: element["dept"]));
            }
            setState(() => list = newList);
          });
        });
      });
    } else {
      setState(() => list = []);
    }
  }
}

class _SearchCell extends StatelessWidget {
  const _SearchCell(this.data, this.last, {Key? key}) : super(key: key);
  final SearchCellData data;
  final bool last;

  @override
  Widget build(BuildContext context) {
    Widget child1 = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: (last)
              ? null
              : const Border(bottom: BorderSide(color: Colors.grey))),
      child:
          Text("${data.name} (${data.dept})", overflow: TextOverflow.ellipsis),
    );

    Widget child2 = SearchAgenda(data);

    return OpenContainerTemplate(child1, child2, () {});
  }
}
