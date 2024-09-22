import 'dart:convert';

import 'package:diacritic/diacritic.dart';
import 'package:ezstudies/search/search_cell_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import '../agenda/agenda.dart';
import '../config/env.dart';
import '../utils/preferences.dart';
import '../utils/templates.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String query = "";
  List<SearchCellData> list = [];
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (!(Preferences.sharedPreferences.getBool(Preferences.helpSearch) ??
        false)) {
      Preferences.sharedPreferences.setBool(Preferences.helpSearch, true).then(
          (value) => showDialog(
              context: context,
              builder: (context) => AlertDialogTemplate(
                      title: AppLocalizations.of(context)!.help,
                      content: AppLocalizations.of(context)!.help_search,
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppLocalizations.of(context)!.ok,
                            ))
                      ])));
    }

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
                          content: AppLocalizations.of(context)!.help_search,
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

    Widget child = Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            TextField(
                autocorrect: false,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search,
                        color: Theme.of(context).colorScheme.onSurface),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(
                                list.isNotEmpty || loading ? 0 : 16),
                            bottomRight: Radius.circular(
                                list.isNotEmpty || loading ? 0 : 16)),
                        borderSide:
                            const BorderSide(color: Colors.transparent)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(
                                list.isNotEmpty || loading ? 0 : 16),
                            bottomRight:
                                Radius.circular(list.isNotEmpty || loading ? 0 : 16)),
                        borderSide: const BorderSide(color: Colors.transparent)),
                    disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(list.isNotEmpty || loading ? 0 : 16), bottomRight: Radius.circular(list.isNotEmpty || loading ? 0 : 16)), borderSide: const BorderSide(color: Colors.transparent)),
                    hintText: AppLocalizations.of(context)!.search.toLowerCase(),
                    fillColor: Theme.of(context).colorScheme.surfaceContainer),
                onSubmitted: (value) => search(),
                onChanged: (value) {
                  query = value;
                  search();
                }),
            Flexible(
                child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: loading ? 1 : list.length,
                      itemBuilder: (context, index) => loading
                          ? Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16))),
                              child: const CircularProgressIndicator())
                          : _SearchCell(list[index],
                              last: index == list.length - 1),
                    )))
          ],
        ));

    return Template(
        title: AppLocalizations.of(context)!.search, menu: menu, child: child);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> search() async {
    if (query.length >= 2) {
      setState(() => loading = true);
      String url = "${Secret.server_url}api/index.php";
      String name =
          Preferences.sharedPreferences.getString(Preferences.name) ?? "";
      String password =
          Preferences.sharedPreferences.getString(Preferences.password) ?? "";
      http.Response response =
          await http.post(Uri.parse(url), body: <String, String>{
        "request": "cyu_search",
        "name": name,
        "password": password,
        "query": Uri.encodeQueryComponent(removeDiacritics(query))
      }).catchError((_) => http.Response("", 404));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        List<dynamic> results = jsonDecode(response.body)["results"];
        List<SearchCellData> newList = [];
        for (var element in results) {
          newList.add(SearchCellData(
              id: element["id"], name: element["text"], dept: element["dept"]));
        }
        setState(() {
          list = newList;
          loading = false;
        });
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
    } else {
      setState(() => list = []);
    }
  }
}

class _SearchCell extends StatelessWidget {
  const _SearchCell(this.data, {this.last = false, Key? key}) : super(key: key);
  final SearchCellData data;
  final bool last;

  @override
  Widget build(BuildContext context) {
    Widget child1 = Container(
      padding: const EdgeInsets.all(10),
      child: Text("${data.name} (${data.dept})",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
    );

    Widget child2 = Agenda(search: true, data: data);

    return OpenContainerTemplate(
        child1: child1,
        child2: child2,
        color: Theme.of(context).colorScheme.surfaceContainer,
        radius: BorderRadius.only(
            bottomLeft: Radius.circular(last ? 16 : 0),
            bottomRight: Radius.circular(last ? 16 : 0)));
  }
}
