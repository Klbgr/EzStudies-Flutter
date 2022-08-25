import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../utils/cipher.dart';
import '../utils/secret.dart';
import '../utils/templates.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  int selectedIndex = 0;
  final PageController pageController = PageController(initialPage: 0);
  final Duration animationDuration = const Duration(milliseconds: 300);
  final Curve animationCurve = Curves.easeInOut;
  String name = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    Widget page1 = const Center(
      child: Text("welcome+illu"),
    );
    Widget page2 = const Center(
      child: Text("features+illu"),
    );
    Widget page3 = Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextFormField(
              decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.name),
                  hintText: AppLocalizations.of(context)!.name.toLowerCase(),
                  icon: const Icon(Icons.person)),
              initialValue: name,
              onChanged: (value) => name = value),
          TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.password),
                  hintText:
                      AppLocalizations.of(context)!.password.toLowerCase(),
                  icon: const Icon(Icons.password)),
              initialValue: password,
              onChanged: (value) => password = value)
        ]));
    List<Widget> pages = [page1, page2, page3];

    Widget child = Stack(children: [
      PageView(
        onPageChanged: (value) => setState(() => selectedIndex = value),
        controller: pageController,
        children: buildPages(pages),
      ),
      Container(
          alignment: Alignment.bottomCenter,
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buildDots(pages.length)))
    ]);

    return Template(AppLocalizations.of(context)!.welcome, child, null, false);
  }

  void next() {
    pageController.nextPage(duration: animationDuration, curve: animationCurve);
  }

  void previous() {
    pageController.previousPage(
        duration: animationDuration, curve: animationCurve);
  }

  void start() {
    if (name.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialogTemplate(AppLocalizations.of(context)!.error, "empty", [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.ok))
        ]),
      );
    } else {
      SecretLoader().load().then((value) {
        String encryptedName = encrypt(name, value.cipherKey);
        String encryptedPassword = encrypt(password, value.cipherKey);
        http.post(Uri.parse(value.serverUrl), body: <String, String>{
          "request": "cyu",
          "name": encryptedName,
          "password": encryptedPassword
        }).then((value) {
          if (value.statusCode == 200 && value.body.isNotEmpty) {
            //TODO insert bd
            SharedPreferences.getInstance().then((value) {
              value.setString("name", encryptedName);
              value.setString("password", encryptedPassword);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const Main()));
            });
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialogTemplate(
                  AppLocalizations.of(context)!.error, "wrong", [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.ok))
              ]),
            );
          }
        });
      });
    }
  }

  List<Widget> buildPages(List<Widget> widgets) {
    const double margin = 20;
    List<Widget> pages = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      List<Widget> children = [widgets[i]];
      if (i == 0 && widgets.length == 1) {
        children.add(Container(
          alignment: Alignment.bottomRight,
          margin: const EdgeInsets.only(bottom: margin, right: margin),
          child: FloatingActionButton.extended(
              onPressed: () => start(),
              label: Text(AppLocalizations.of(context)!.begin),
              icon: const Icon(Icons.arrow_forward)),
        ));
      } else if (i == 0) {
        children.add(Container(
          alignment: Alignment.bottomRight,
          margin: const EdgeInsets.only(bottom: margin, right: margin),
          child: FloatingActionButton.extended(
              onPressed: () => next(),
              label: Text(AppLocalizations.of(context)!.next),
              icon: const Icon(Icons.arrow_forward)),
        ));
      } else if (i == widgets.length - 1) {
        children.add(Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(bottom: margin, left: margin),
          child: FloatingActionButton.extended(
              heroTag: "previous",
              onPressed: () => previous(),
              label: Text(AppLocalizations.of(context)!.previous),
              icon: const Icon(Icons.arrow_back)),
        ));
        children.add(Container(
          alignment: Alignment.bottomRight,
          margin: const EdgeInsets.only(bottom: margin, right: margin),
          child: FloatingActionButton.extended(
              onPressed: () => start(),
              label: Text(AppLocalizations.of(context)!.begin),
              icon: const Icon(Icons.arrow_forward)),
        ));
      } else {
        children.add(Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(bottom: margin, left: margin),
          child: FloatingActionButton.extended(
              onPressed: () => previous(),
              label: Text(AppLocalizations.of(context)!.previous),
              icon: const Icon(Icons.arrow_back)),
        ));
        children.add(Container(
          alignment: Alignment.bottomRight,
          margin: const EdgeInsets.only(bottom: margin, right: margin),
          child: FloatingActionButton.extended(
              onPressed: () => next(),
              label: Text(AppLocalizations.of(context)!.next),
              icon: const Icon(Icons.arrow_forward)),
        ));
      }
      pages.add(Stack(children: children));
    }
    return pages;
  }

  List<Widget> buildDots(int pageCount) {
    List<Widget> dots = <Widget>[];
    for (int i = 0; i < pageCount; i++) {
      dots.add(GestureDetector(
          child: Icon(
              (selectedIndex == i) ? Icons.circle : Icons.circle_outlined,
              size: 10),
          onTap: () => pageController.animateToPage(i,
              duration: animationDuration, curve: animationCurve)));
    }
    return dots;
  }
}
