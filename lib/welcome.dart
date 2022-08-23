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
  final PageController pageController = PageController(initialPage: 0);
  final animationDuration = const Duration(milliseconds: 300);
  final animationCurve = Curves.easeInOut;
  @override
  Widget build(BuildContext context) {
    Widget child = PageView(
      controller: pageController,
      children: [
        Stack(children: [
          Container(
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.only(bottom: 20, right: 20),
            child: FloatingActionButton.extended(
                onPressed: () => next(),
                label: const Text("next"),
                icon: const Icon(Icons.arrow_forward)),
          )
        ]),
        Stack(children: [
          Container(
            alignment: Alignment.bottomLeft,
            margin: const EdgeInsets.only(bottom: 20, left: 20),
            child: FloatingActionButton.extended(
                onPressed: () => previous(),
                label: const Text("previous"),
                icon: const Icon(Icons.arrow_back)),
          ),
          Container(
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.only(bottom: 20, right: 20),
            child: FloatingActionButton.extended(
                onPressed: () => next(),
                label: const Text("next"),
                icon: const Icon(Icons.arrow_forward)),
          )
        ]),
        Stack(children: [
          Container(
            alignment: Alignment.bottomLeft,
            margin: const EdgeInsets.only(bottom: 20, left: 20),
            child: FloatingActionButton.extended(
                heroTag: "previous",
                onPressed: () => previous(),
                label: const Text("previous"),
                icon: const Icon(Icons.arrow_back)),
          ),
          Container(
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.only(bottom: 20, right: 20),
            child: FloatingActionButton.extended(
                onPressed: () => start(),
                label: const Text("start"),
                icon: const Icon(Icons.arrow_forward)),
          )
        ])
      ],
    );

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
}
