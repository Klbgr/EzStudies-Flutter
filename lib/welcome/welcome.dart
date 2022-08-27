import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../utils/cipher.dart';
import '../utils/preferences.dart';
import '../utils/secret.dart';
import '../utils/style.dart';
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
    Widget page1 = Center(
      child: Text("welcome+illu", style: TextStyle(color: Style.text)),
    );
    Widget page2 = Center(
      child: Text("features+illu", style: TextStyle(color: Style.text)),
    );
    Widget page3 = Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextFormFieldTemplate(
              AppLocalizations.of(context)!.name, Icons.person,
              onChanged: (value) => name = value),
          TextFormFieldTemplate(
              AppLocalizations.of(context)!.password, Icons.password,
              onChanged: (value) => password = value, hidden: true)
        ]));
    List<Widget> pages = [page1, page2, page3];

    Widget child = Stack(children: [
      PageView(
        onPageChanged: (value) {
          name = "";
          password = "";
          setState(() => selectedIndex = value);
        },
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

    return Template(AppLocalizations.of(context)!.welcome, child, back: false);
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
              child: Text(AppLocalizations.of(context)!.ok,
                  style: TextStyle(color: Style.primary)))
        ]),
      );
    } else {
      String encryptedName = encrypt(name, Secret.cipherKey);
      String encryptedPassword = encrypt(password, Secret.cipherKey);
      http.post(Uri.parse(Secret.serverUrl), body: <String, String>{
        "request": "cyu",
        "name": encryptedName,
        "password": encryptedPassword
      }).then((value) {
        if (value.statusCode == 200 && value.body.isNotEmpty) {
          //TODO insert bd
          Preferences.sharedPreferences.setString("name", encryptedName);
          Preferences.sharedPreferences
              .setString("password", encryptedPassword);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => Main(reloadTheme: () {})));
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
              backgroundColor: Style.primary,
              onPressed: () => start(),
              label: Text(AppLocalizations.of(context)!.begin,
                  style: TextStyle(color: Style.text)),
              icon: Icon(Icons.arrow_forward, color: Style.text)),
        ));
      } else if (i == 0) {
        children.add(Container(
          alignment: Alignment.bottomRight,
          margin: const EdgeInsets.only(bottom: margin, right: margin),
          child: FloatingActionButton.extended(
              backgroundColor: Style.primary,
              onPressed: () => next(),
              label: Text(AppLocalizations.of(context)!.next,
                  style: TextStyle(color: Style.text)),
              icon: Icon(Icons.arrow_forward, color: Style.text)),
        ));
      } else if (i == widgets.length - 1) {
        children.add(Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(bottom: margin, left: margin),
          child: FloatingActionButton.extended(
              backgroundColor: Style.primary,
              heroTag: "previous",
              onPressed: () => previous(),
              label: Text(AppLocalizations.of(context)!.previous,
                  style: TextStyle(color: Style.text)),
              icon: Icon(Icons.arrow_back, color: Style.text)),
        ));
        children.add(Container(
          alignment: Alignment.bottomRight,
          margin: const EdgeInsets.only(bottom: margin, right: margin),
          child: FloatingActionButton.extended(
              backgroundColor: Style.primary,
              onPressed: () => start(),
              label: Text(AppLocalizations.of(context)!.begin,
                  style: TextStyle(color: Style.text)),
              icon: Icon(Icons.arrow_forward, color: Style.text)),
        ));
      } else {
        children.add(Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(bottom: margin, left: margin),
          child: FloatingActionButton.extended(
              backgroundColor: Style.primary,
              onPressed: () => previous(),
              label: Text(AppLocalizations.of(context)!.previous,
                  style: TextStyle(color: Style.text)),
              icon: Icon(Icons.arrow_back, color: Style.text)),
        ));
        children.add(Container(
          alignment: Alignment.bottomRight,
          margin: const EdgeInsets.only(bottom: margin, right: margin),
          child: FloatingActionButton.extended(
              backgroundColor: Style.primary,
              onPressed: () => next(),
              label: Text(AppLocalizations.of(context)!.next,
                  style: TextStyle(color: Style.text)),
              icon: Icon(Icons.arrow_forward, color: Style.text)),
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
              size: 10,
              color: Style.text),
          onTap: () => pageController.animateToPage(i,
              duration: animationDuration, curve: animationCurve)));
    }
    return dots;
  }
}
