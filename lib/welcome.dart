import 'package:ezstudies/templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
        Center(
          child: TextButton(
            child: const Text("yo"),
            onPressed: () {
              next();
            },
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                child: const Text('previous'),
                onPressed: () {
                  previous();
                },
              ),
              TextButton(
                child: const Text('next'),
                onPressed: () {
                  next();
                },
              ),
            ],
          ),
        ),
        Center(
          child: TextButton(
            child: const Text('start'),
            onPressed: () {

            },
          ),
        ),
      ],
    );

    return Template(AppLocalizations.of(context)!.welcome, child, null, false);
  }

  void next() {
    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void previous() {
    pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }
}
