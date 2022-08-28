import 'dart:convert';

import 'package:ezstudies/search/search_cell_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import '../agenda/agenda.dart';
import '../utils/preferences.dart';
import '../utils/secret.dart';
import '../utils/style.dart';
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
                            style: TextStyle(color: Style.primary)))
                  ]));
          break;
      }
    });

    Widget child = Container(
        margin: EdgeInsets.only(
            left: 20,
            right: 20,
            top: MediaQuery.of(context).size.height * 0.25),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                    child: TextField(
                        autocorrect: false,
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
                            hintText: AppLocalizations.of(context)!.search,
                            hintStyle: TextStyle(color: Style.hint)),
                        onSubmitted: (value) => search(),
                        onChanged: (value) {
                          query = value;
                          search();
                        })),
                IconButton(
                    icon: Icon(Icons.search, color: Style.text),
                    onPressed: () => search())
              ],
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: list.length,
                  itemBuilder: (context, index) => _SearchCell(list[index]),
                ))
          ],
        ));

    return Template(AppLocalizations.of(context)!.search, child, menu: menu);
  }

  void search() {
    if (query.length >= 3) {
      String url = Secret.serverUrl;
      String name = Preferences.sharedPreferences.getString("name") ?? "";
      String password =
          Preferences.sharedPreferences.getString("password") ?? "";
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
              id: element["id"], name: element["text"], dept: element["dept"]));
        }
        setState(() => list = newList);
      });
    } else {
      setState(() => list = []);
    }
  }
}

class _SearchCell extends StatelessWidget {
  const _SearchCell(this.data, {Key? key}) : super(key: key);
  final SearchCellData data;

  @override
  Widget build(BuildContext context) {
    Widget child1 = Container(
      padding: const EdgeInsets.all(10),
      child: Text("${data.name} (${data.dept})",
          overflow: TextOverflow.ellipsis, style: TextStyle(color: Style.text)),
    );

    Widget child2 = Agenda(search: true, data: data);

    return OpenContainerTemplate(child1, child2, () {},
        elevation: 6, trigger: (_) {});
  }
}
