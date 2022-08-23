import 'package:ezstudies/templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'main.dart';

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

  @override
  Widget build(BuildContext context) {
    const List<Widget> pages = [Text("soon"), Text("soon"), Text("soon")];
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
    pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void previous() {
    pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void start() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const Main()));
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
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut)));
    }
    return dots;
  }
}
